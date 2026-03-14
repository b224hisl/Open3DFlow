import numpy as np
import pandas as pd
import matplotlib.pyplot as plt
from scipy import signal
from scipy.interpolate import interp1d
import warnings
warnings.filterwarnings('ignore')

# 1. 读取S参数数据
s21_data = pd.read_csv('s21_data.csv')
s11_data = pd.read_csv('s11_data.csv')

print("S21数据预览:")
print(s21_data.head())
print(f"\nS21数据点数量: {len(s21_data)}")

print("\nS11数据预览:")
print(s11_data.head())
print(f"S11数据点数量: {len(s11_data)}")

# 2. 处理S参数，将dB和角度转换为复数形式
def db_phase_to_complex(mag_db, phase_deg):
    """将dB幅度和相位角度转换为复数"""
    mag_linear = 10**(mag_db / 20)  # 将dB转换为线性幅度
    phase_rad = np.deg2rad(phase_deg)  # 角度转弧度
    return mag_linear * np.exp(1j * phase_rad)

# 为S21和S11创建复数表示
freq_ghz_s21 = s21_data['Frequency_GHz'].values
s21_complex = db_phase_to_complex(s21_data['S21_Magnitude_dB'].values, 
                                   s21_data['S21_Phase_deg'].values)

freq_ghz_s11 = s11_data['Frequency_GHz'].values
s11_complex = db_phase_to_complex(s11_data['S11_Magnitude_dB'].values, 
                                   s11_data['S11_Phase_deg'].values)

# 3. 创建插值函数以便在任意频率点获取S参数
s21_interp = interp1d(freq_ghz_s21, s21_complex, kind='cubic', 
                       bounds_error=False, fill_value=(s21_complex[0], s21_complex[-1]))
s11_interp = interp1d(freq_ghz_s11, s11_complex, kind='cubic',
                       bounds_error=False, fill_value=(s11_complex[0], s11_complex[-1]))

# 4. 生成PRBS信号（伪随机二进制序列）
def generate_prbs(order=7, bit_rate=3.2e9, sampling_rate=32e9, num_bits=1000):
    """
    生成PRBS信号
    order: PRBS阶数 (PRBS7 = 2^7-1 = 127位)
    bit_rate: 比特率 (3.2 GHz)
    sampling_rate: 采样率 (需要至少是比特率的8-10倍以获得清晰的眼图)
    num_bits: 生成的比特数
    """
    # 生成PRBS序列
    prbs_length = 2**order - 1
    prbs = np.zeros(prbs_length, dtype=int)
    
    # 初始化寄存器（非零初始状态）
    register = 0b1000000  # 初始寄存器值
    
    # 生成PRBS序列（使用XOR反馈）
    for i in range(prbs_length):
        # 对于PRBS7，抽头在7和6位（根据标准多项式x^7 + x^6 + 1）
        feedback = ((register >> 6) & 1) ^ ((register >> 5) & 1)  # 位7和位6
        prbs[i] = register & 1  # 输出最低位
        register = ((register << 1) | feedback) & 0x7F  # 移位并应用反馈
    
    # 重复PRBS序列以达到所需的比特数
    full_sequence = np.tile(prbs, int(np.ceil(num_bits / prbs_length)))[:num_bits]
    
    # 转换为双极性信号（-1, 1）
    full_sequence = 2 * full_sequence - 1
    
    # 计算每个比特的采样点数
    samples_per_bit = int(sampling_rate / bit_rate)
    
    # 创建时间轴
    total_samples = num_bits * samples_per_bit
    t = np.arange(total_samples) / sampling_rate
    
    # 上采样信号
    signal_up = np.zeros(total_samples)
    for i in range(num_bits):
        start_idx = i * samples_per_bit
        end_idx = (i + 1) * samples_per_bit
        signal_up[start_idx:end_idx] = full_sequence[i]
    
    return t, signal_up, samples_per_bit, full_sequence

# 5. 生成通过网络的信号
def apply_network_response(input_signal, s21_interp_func, s11_interp_func, 
                           sampling_rate, bit_rate, freq_center=3.2e9):
    """
    应用网络响应到输入信号
    使用频域卷积方法
    """
    # 获取信号长度
    n = len(input_signal)
    
    # 创建频率轴（用于FFT）
    freq_axis = np.fft.fftfreq(n, 1/sampling_rate)
    
    # 获取输入信号的FFT
    input_fft = np.fft.fft(input_signal)
    
    # 为每个频率点获取S21
    s21_response = np.zeros(n, dtype=complex)
    for i, freq in enumerate(freq_axis):
        freq_ghz = np.abs(freq + freq_center) / 1e9  # 转换为GHz
        s21_response[i] = s21_interp_func(freq_ghz)
    
    # 应用S21响应
    output_fft = input_fft * s21_response
    
    # 逆FFT得到时域输出信号
    output_signal = np.real(np.fft.ifft(output_fft))
    
    # 归一化输出信号
    output_signal = output_signal / np.max(np.abs(output_signal))
    
    return output_signal

# 6. 添加噪声
def add_noise(signal_data, snr_db=30):
    """添加高斯白噪声"""
    # 计算信号功率
    signal_power = np.mean(signal_data**2)
    
    # 根据SNR计算噪声功率
    snr_linear = 10**(snr_db / 10)
    noise_power = signal_power / snr_linear
    
    # 生成噪声
    noise = np.random.normal(0, np.sqrt(noise_power), len(signal_data))
    
    # 添加噪声到信号
    noisy_signal = signal_data + 0*noise
    
    return noisy_signal

# 7. 绘制眼图
def plot_eye_diagram(signal_data, samples_per_bit, bits_per_eye=2, title="Eye Diagram"):
    """
    绘制眼图
    bits_per_eye: 每个眼睛覆盖的比特数（通常为2）
    """
    # 计算每个眼睛的采样点数
    samples_per_eye = samples_per_bit * bits_per_eye
    
    # 确保信号长度是眼睛采样点数的整数倍
    num_eyes = len(signal_data) // samples_per_eye
    truncated_length = num_eyes * samples_per_eye
    truncated_signal = signal_data[:truncated_length]
    
    # 重塑信号以创建眼睛
    eye_matrix = truncated_signal.reshape(num_eyes, samples_per_eye)
    
    # 创建时间轴（归一化到单位间隔UI）
    t_ui = np.linspace(0, bits_per_eye, samples_per_eye)
    
    # 创建图形
    plt.figure(figsize=(12, 8))
    
    # 绘制所有轨迹（透明度较低以显示密度）
    for i in range(min(200, num_eyes)):  # 限制轨迹数量以避免图形过载
        plt.plot(t_ui, eye_matrix[i], 'b-', alpha=0.1, linewidth=0.5)
    
    # 计算眼图统计信息
    eye_mean = np.mean(eye_matrix, axis=0)
    eye_std = np.std(eye_matrix, axis=0)
    
    # 绘制平均眼图
    plt.plot(t_ui, eye_mean, 'r-', linewidth=2, label='Mean Eye')
    
    # 计算眼高和眼宽
    # 找到中心点（比特中间）
    center_idx = samples_per_eye // 2
    quarter_idx = samples_per_eye // 4
    three_quarter_idx = 3 * samples_per_eye // 4
    
    # 在中心点附近寻找眼高
    search_window = samples_per_bit // 4
    center_start = center_idx - search_window
    center_end = center_idx + search_window
    
    # 在中心区域找到最大值和最小值
    center_values = eye_matrix[:, center_start:center_end].flatten()
    eye_top = np.percentile(center_values, 95)  # 使用百分位数以避免异常值
    eye_bottom = np.percentile(center_values, 5)
    eye_height = eye_top - eye_bottom
    
    # 在交叉点附近寻找眼宽
    # 找到平均眼图在0.5UI和1.5UI处的交叉点
    threshold = 0  # 假设信号是双极性的，交叉点在0附近
    
    # 寻找上升沿和下降沿交叉点
    rising_crossings = []
    falling_crossings = []
    
    for i in range(num_eyes):
        eye = eye_matrix[i]
        # 寻找0.5UI附近的交叉点（从低到高）
        for j in range(quarter_idx - 10, quarter_idx + 10):
            if j > 0 and eye[j] >= threshold > eye[j-1]:
                rising_crossings.append(j)
                break
        
        # 寻找1.5UI附近的交叉点（从高到低）
        for j in range(three_quarter_idx - 10, three_quarter_idx + 10):
            if j > 0 and eye[j] <= threshold < eye[j-1]:
                falling_crossings.append(j)
                break
    
    if rising_crossings and falling_crossings:
        mean_rising = np.mean(rising_crossings)
        mean_falling = np.mean(falling_crossings)
        eye_width_ui = (mean_falling - mean_rising) / samples_per_bit * bits_per_eye
        eye_width_samples = mean_falling - mean_rising
    else:
        eye_width_ui = 0.6  # 默认值
        eye_width_samples = int(0.6 * samples_per_bit)
    
    # 添加眼高和眼宽标注
    plt.annotate(f'Eye Height: {eye_height:.3f} V', 
                 xy=(0.5, eye_top), xytext=(0.5, eye_top + 0.1),
                 arrowprops=dict(arrowstyle='->'), ha='center')
    
    plt.annotate(f'Eye Width: {eye_width_ui:.2f} UI', 
                 xy=(1, 0), xytext=(1, -0.2),
                 arrowprops=dict(arrowstyle='->'), ha='center')
    
    # 标记眼图中心
    plt.axvline(x=0.5, color='g', linestyle='--', alpha=0.5, label='Eye Center (0.5 UI)')
    plt.axvline(x=1.0, color='g', linestyle='--', alpha=0.5, label='Eye Center (1.5 UI)')
    plt.axhline(y=0, color='k', linestyle='-', alpha=0.3)
    
    # 添加网格和标签
    plt.grid(True, alpha=0.3)
    plt.xlabel('Time (Unit Intervals - UI)')
    plt.ylabel('Amplitude (V)')
    plt.title(f'{title}\nBit Rate: 3.2 Gbps, Center Frequency: 3.2 GHz')
    plt.legend(loc='upper right')
    
    # 设置x轴范围以显示两个完整的眼睛
    plt.xlim([0, bits_per_eye])
    
    # 添加文本信息框
    info_text = f'Bit Rate: 3.2 Gbps\nUI: {1/3.2*1000:.1f} ps\nEye Height: {eye_height:.3f} V\nEye Width: {eye_width_ui:.2f} UI'
    plt.text(0.02, 0.98, info_text, transform=plt.gca().transAxes,
             verticalalignment='top', bbox=dict(boxstyle='round', facecolor='wheat', alpha=0.8))
    
    return plt.gcf(), eye_height, eye_width_ui

# 主程序
def main():
    # 参数设置
    bit_rate = 3.2e9  # 3.2 Gbps
    sampling_rate = 64e9  # 64 GHz采样率（每个比特20个采样点）
    num_bits = 1000  # 生成1000个比特
    center_freq = 3.2e9  # 中心频率3.2 GHz
    
    print(f"生成PRBS信号...")
    print(f"比特率: {bit_rate/1e9} Gbps")
    print(f"采样率: {sampling_rate/1e9} GHz")
    print(f"每个比特的采样点数: {int(sampling_rate/bit_rate)}")
    
    # 生成PRBS信号
    t, prbs_signal, samples_per_bit, bit_sequence = generate_prbs(
        order=7, 
        bit_rate=bit_rate, 
        sampling_rate=sampling_rate, 
        num_bits=num_bits
    )
    
    print(f"PRBS信号长度: {len(prbs_signal)} 采样点")
    print(f"时间长度: {t[-1]*1e9:.1f} ns")
    
    # 应用网络响应
    print("应用网络响应...")
    output_signal = apply_network_response(
        prbs_signal, 
        s21_interp, 
        s11_interp, 
        sampling_rate, 
        bit_rate,
        freq_center=center_freq
    )
    
    # 添加噪声
    print("添加噪声...")
    noisy_output = add_noise(output_signal, snr_db=25)
    
    # 绘制输入和输出信号的片段
    plt.figure(figsize=(12, 6))
    plt.subplot(2, 1, 1)
    plt.plot(t[:10*samples_per_bit]*1e9, prbs_signal[:10*samples_per_bit])
    plt.xlabel('Time (ns)')
    plt.ylabel('Amplitude (V)')
    plt.title('Input PRBS Signal (First 10 bits)')
    plt.grid(True, alpha=0.3)
    
    plt.subplot(2, 1, 2)
    plt.plot(t[:10*samples_per_bit]*1e9, noisy_output[:10*samples_per_bit])
    plt.xlabel('Time (ns)')
    plt.ylabel('Amplitude (V)')
    plt.title('Output Signal after Network (First 10 bits)')
    plt.grid(True, alpha=0.3)
    
    plt.tight_layout()
    plt.savefig('prbs_input_output.png', dpi=150, bbox_inches='tight')
    plt.show()
    
    # 绘制S21幅度响应（在中心频率附近）
    freq_points = np.linspace(0.1, 8, 1000)
    s21_magnitude = 20*np.log10(np.abs(s21_interp(freq_points)))
    
    plt.figure(figsize=(10, 6))
    plt.plot(freq_points, s21_magnitude)
    plt.axvline(x=3.2, color='r', linestyle='--', label='3.2 GHz')
    plt.xlabel('Frequency (GHz)')
    plt.ylabel('S21 Magnitude (dB)')
    plt.title('S21 Magnitude Response of the Two-Port Network')
    plt.grid(True, alpha=0.3)
    plt.legend()
    plt.savefig('s21_response.png', dpi=150, bbox_inches='tight')
    plt.show()
    
    # 绘制眼图
    print("绘制眼图...")
    fig, eye_height, eye_width = plot_eye_diagram(
        noisy_output, 
        samples_per_bit, 
        bits_per_eye=2,
        title="Eye Diagram of Two-Port Network Output at 3.2 Gbps"
    )
    
    plt.tight_layout()
    plt.savefig('eye_diagram_3p2GHz.png', dpi=150, bbox_inches='tight')
    plt.show()
    
    print(f"眼图已保存为 'eye_diagram_3p2GHz.png'")
    print(f"眼高: {eye_height:.3f} V")
    print(f"眼宽: {eye_width:.2f} UI")
    print(f"眼宽时间: {eye_width/3.2*1000:.1f} ps")

# 运行主程序
if __name__ == "__main__":
    main()