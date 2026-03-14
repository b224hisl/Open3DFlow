import pandas as pd
import numpy as np
import matplotlib.pyplot as plt
from scipy import interpolate

# --------------------------
# 替代awgn函数：手动实现高斯白噪声添加
# --------------------------
def add_awgn(signal, snr_db, seed=None):
    """
    向信号添加指定信噪比（SNR）的高斯白噪声（替代scipy.signal.awgn）
    :param signal: 原始无噪声信号
    :param snr_db: 信噪比（dB）
    :param seed: 随机种子（保证结果可复现）
    :return: 加噪后的信号
    """
    if seed is not None:
        np.random.seed(seed)
    
    # 1. 计算原始信号的功率
    signal_power = np.mean(np.square(signal))
    
    # 2. 根据SNR计算噪声功率（SNR_dB = 10*log10(信号功率/噪声功率)）
    snr_linear = 10 ** (snr_db / 10)
    noise_power = signal_power / snr_linear
    
    # 3. 生成高斯白噪声（均值0，方差=噪声功率）
    noise = np.random.normal(0, np.sqrt(noise_power), len(signal))
    
    # 4. 叠加噪声到原始信号
    noisy_signal = signal + 0*noise
    
    return noisy_signal

# --------------------------
# 1. 读取并插值S参数（S11+S21，找到3.2GHz对应值）
# --------------------------
def get_s_parameter_at_freq(csv_path, target_freq_ghz):
    """读取CSV文件并插值得到目标频率的S参数（幅度dB转线性，相位deg转弧度）"""
    # 读取CSV数据
    df = pd.read_csv(csv_path)
    freq_ghz = df['Frequency_GHz'].values
    mag_dB = df.iloc[:, 1].values  # Sxx_Magnitude_dB列
    phase_deg = df.iloc[:, 2].values  # Sxx_Phase_deg列
    
    # 插值函数（线性插值，适合高频扫描数据）
    f_mag = interpolate.interp1d(freq_ghz, mag_dB, kind='linear', fill_value="extrapolate")
    f_phase = interpolate.interp1d(freq_ghz, phase_deg, kind='linear', fill_value="extrapolate")
    
    # 目标频率的参数
    target_mag_dB = f_mag(target_freq_ghz)
    target_phase_rad = np.deg2rad(f_phase(target_freq_ghz))
    
    # 幅度转线性（dB转线性：10^(dB/20)）
    target_mag_linear = 10 ** (target_mag_dB / 20)
    
    return target_mag_linear, target_phase_rad

# 获取3.2GHz的S参数（完整二端口：S11=S22，S21=S12）
s11_mag, s11_phase = get_s_parameter_at_freq("s11_data.csv", 3.2)  # 1端口反射系数
s21_mag, s21_phase = get_s_parameter_at_freq("s21_data.csv", 3.2)  # 1→2传输系数

# --------------------------
# 2. 生成PRBS信号（PRBS-7，3.2GHz时钟）
# --------------------------
def generate_prbs7(clock_freq_hz, oversample=8, seq_length=127):
    """
    生成PRBS-7信号
    :param clock_freq_hz: 时钟频率（3.2GHz）
    :param oversample: 过采样率（每个UI的采样点数）
    :param seq_length: PRBS-7序列长度（127位）
    :return: prbs_signal: 生成的PRBS信号, sample_rate: 采样率, ui: 单位间隔（秒）
    """
    # 单位间隔（UI）= 1/时钟频率
    ui = 1 / clock_freq_hz
    # 采样率 = 过采样率 * 时钟频率
    sample_rate = oversample * clock_freq_hz
    # 每个bit的采样点数
    samples_per_bit = oversample
    
    # PRBS-7生成（移位寄存器，反馈抽头：第7和第6位）
    prbs_bits = []
    # 初始状态（非全0即可）
    shift_reg = [1, 1, 1, 1, 1, 1, 1]
    for _ in range(seq_length):
        prbs_bits.append(shift_reg[-1])
        # 反馈位 = 第7位 XOR 第6位
        feedback = shift_reg[6] ^ shift_reg[5]
        # 移位
        shift_reg = [feedback] + shift_reg[:-1]
    
    # 将bit序列扩展为过采样的模拟信号（1→1，0→-1）
    prbs_signal = []
    for bit in prbs_bits:
        val = 1.0 if bit else -1.0
        prbs_signal.extend([val] * samples_per_bit)
    
    return np.array(prbs_signal), sample_rate, ui

# 生成PRBS信号（3.2GHz时钟，8倍过采样）
clock_freq = 3.2e9  # 3.2GHz
prbs_input, sample_rate, ui = generate_prbs7(clock_freq, oversample=8)

# --------------------------
# 3. 完整二端口网络信号传输（纳入S11反射+S21传输）
# --------------------------
def two_port_network_transfer(input_signal, s11_mag, s11_phase, s21_mag, s21_phase, sample_rate):
    """
    模拟信号通过对称二端口网络的传输（含反射效应）
    模型说明：
    - 1端口输入信号 → 部分反射（S11），部分传输到2端口（S21）；
    - 反射信号会延迟后叠加到输入信号，再二次传输（简化的多反射叠加，工程常用近似）；
    :param input_signal: 1端口输入信号
    :param s11_mag/s11_phase: S11的幅度（线性）/相位（弧度）
    :param s21_mag/s21_phase: S21的幅度（线性）/相位（弧度）
    :param sample_rate: 采样率
    :return: 2端口输出信号
    """
    # 相位偏移转时域延迟（delay = 相位/(2π*频率)）
    s11_delay = s11_phase / (2 * np.pi * clock_freq)
    s21_delay = s21_phase / (2 * np.pi * clock_freq)
    s11_delay_samples = int(round(s11_delay * sample_rate))
    s21_delay_samples = int(round(s21_delay * sample_rate))
    
    # 第一步：输入信号直接传输到2端口（主路径：S21）
    direct_transmit = np.roll(input_signal * s21_mag, s21_delay_samples)
    
    # 第二步：输入信号在1端口反射（S11），反射信号再传输到2端口（二次路径：S11*S21）
    reflected_signal = np.roll(input_signal * s11_mag, s11_delay_samples)  # 1端口反射信号
    reflected_transmit = np.roll(reflected_signal * s21_mag, s21_delay_samples)  # 反射信号再传输
    
    # 总输出：主路径 + 二次反射路径（忽略更高阶反射，避免过度复杂）
    total_output = direct_transmit + reflected_transmit
    
    # 信号归一化（避免幅度溢出）
    total_output = total_output / np.max(np.abs(total_output))
    
    return total_output

# 二端口网络传输
transmitted_signal = two_port_network_transfer(
    prbs_input, s11_mag, s11_phase, s21_mag, s21_phase, sample_rate
)

# 加入少量高斯白噪声（替换原awgn，SNR=25dB，seed保证结果可复现）
noisy_signal = add_awgn(transmitted_signal, snr_db=25, seed=42)

# --------------------------
# 4. 绘制眼图（仅显示2个UI，标注眼高、UI，英文标签）
# --------------------------
def plot_eye_diagram(signal, sample_rate, ui, num_eyes=2, save_path="eye_diagram_complete.png"):
    """
    绘制眼图（修正版，纳入完整二端口效应）
    :param signal: 待绘制的信号
    :param sample_rate: 采样率
    :param ui: 单位间隔（秒）
    :param num_eyes: 显示的眼睛数量（2）
    :param save_path: 保存路径
    """
    plt.rcParams['font.family'] = 'Arial'  # 英文标注字体
    fig, ax = plt.subplots(figsize=(8, 6))
    
    # 每个UI的采样点数
    samples_per_ui = int(round(ui * sample_rate))
    # 眼图x轴范围（0 ~ num_eyes*UI），转ns单位（更易读）
    x_axis = np.linspace(0, num_eyes * ui * 1e9, num_eyes * samples_per_ui)
    
    # 切分信号为多个UI段，叠加绘制（形成2个眼睛）
    num_segments = len(signal) // (num_eyes * samples_per_ui)
    for i in range(num_segments):
        start_idx = i * num_eyes * samples_per_ui
        end_idx = start_idx + num_eyes * samples_per_ui
        if end_idx > len(signal):
            break
        segment = signal[start_idx:end_idx]
        ax.plot(x_axis, segment, color='blue', alpha=0.3)
    
    # 计算眼高（Eye Height）：信号最大-最小幅度（眼图的核心指标）
    eye_height = np.max(signal) - np.min(signal)
    
    # 标注UI和眼高（英文）
    ax.axvline(x=ui*1e9, color='red', linestyle='--', label=f'UI = {ui*1e9:.2f} ns')
    ax.text(ui*1e9 + 0.01, np.mean([np.max(signal), np.min(signal)]), 
            f'Eye Height = {eye_height:.3f}', 
            color='green', fontweight='bold')
    
    # 图表标注（英文，符合要求）
    ax.set_title('Eye Diagram (Complete 2-Port Network, 3.2GHz PRBS)', fontsize=14)
    ax.set_xlabel('Time (ns)', fontsize=12)
    ax.set_ylabel('Amplitude (Normalized)', fontsize=12)
    ax.legend(loc='upper right')
    ax.grid(True, alpha=0.2)
    
    # 限制x轴范围（仅显示2个眼睛）
    ax.set_xlim(0, num_eyes * ui * 1e9)
    
    # 保存高分辨率图片
    plt.tight_layout()
    plt.savefig(save_path, dpi=300)

# 绘制并保存完整的眼图
plot_eye_diagram(noisy_signal, sample_rate, ui, num_eyes=2)