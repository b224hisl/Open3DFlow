import pandas as pd
import numpy as np
import matplotlib.pyplot as plt
from scipy import interpolate
import warnings
warnings.filterwarnings('ignore')  # 忽略无关警告

# ===================== 1. 读取并处理S21数据 =====================
# 读取CSV文件
df = pd.read_csv('s21_data.csv')

# 提取频率、S21幅度(dB)、S21相位(度)
freq_ghz = df['Frequency_GHz'].values
s21_mag_db = df['S21_Magnitude_dB'].values
s21_phase_deg = df['S21_Phase_deg'].values

# 插值函数：根据频率查找对应的S21幅度和相位（线性插值）
f_mag = interpolate.interp1d(freq_ghz, s21_mag_db, kind='linear', fill_value='extrapolate')
f_phase = interpolate.interp1d(freq_ghz, s21_phase_deg, kind='linear', fill_value='extrapolate')

# 获取3.2GHz处的S21参数
target_freq = 3.2  # GHz
s21_32g_mag_db = f_mag(target_freq)
s21_32g_phase_deg = f_phase(target_freq)

# 转换为线性幅度和弧度相位（工程常用格式）
s21_mag_linear = 10 ** (s21_32g_mag_db / 20)  # dB转线性幅度
s21_phase_rad = np.deg2rad(s21_32g_phase_deg)  # 度转弧度

print(f"3.2GHz处S21参数：")
print(f"幅度: {s21_32g_mag_db:.4f} dB (线性: {s21_mag_linear:.4f})")
print(f"相位: {s21_32g_phase_deg:.4f} 度 (弧度: {s21_phase_rad:.4f})")

# ===================== 2. 生成PRBS序列和时域信号 =====================
# 系统参数定义（3.2GHz PRBS）
bit_rate = 3.2e9  # 码率: 3.2 Gb/s
UI = 1 / bit_rate  # 单位间隔 (Unit Interval): ~312.5 ps
sample_rate = 16 * bit_rate  # 采样率：码率的16倍（过采样保证精度）
samples_per_bit = int(sample_rate / bit_rate)  # 每个码元的采样点数: 16
num_bits = 1023  # PRBS7序列长度（2^7-1），保证序列足够长

# 生成PRBS7序列（伪随机二进制序列）
def generate_prbs7(length):
    """生成PRBS7序列（二进制：0/1）"""
    prbs = np.ones(length, dtype=int)
    # PRBS7反馈抽头: x7 = x6 + x2 (模2)
    for i in range(7, length):
        prbs[i] = (prbs[i-6] + prbs[i-2]) % 2
    return prbs

# 生成PRBS序列并转换为电平平移（0→-1，1→1）
prbs_seq = generate_prbs7(num_bits)
prbs_seq = np.where(prbs_seq == 0, -1, 1)

# 生成基带PRBS时域信号（矩形脉冲）
baseband_signal = np.repeat(prbs_seq, samples_per_bit)  # 每个码元扩展为多个采样点
time_base = np.arange(len(baseband_signal)) / sample_rate  # 时域轴

# 应用二端口网络S21特性（幅度衰减+相位偏移）
# 相位偏移转换为时域延迟：phase = 2πfτ → τ = phase/(2πf)
time_delay = s21_phase_rad / (2 * np.pi * target_freq * 1e9)
# 信号幅度缩放 + 相位延迟（简化为时间延迟）
transmitted_signal = s21_mag_linear * np.roll(baseband_signal, int(time_delay * sample_rate))

# 加入高斯噪声（少许扰动，信噪比~20dB）
noise_power = 0 * np.var(transmitted_signal)  # 噪声功率
noise = np.random.normal(0, np.sqrt(noise_power), len(transmitted_signal))
received_signal = transmitted_signal + noise

# ===================== 3. 绘制眼图 =====================
# 眼图绘制参数：只显示2个UI，取足够多的码元段叠加
num_segments = min(500, num_bits)  # 取前500个码元段绘制（保证眼图清晰）
eye_samples = 2 * samples_per_bit  # 每个眼图显示2个UI的采样点
eye_signal = np.zeros((num_segments, eye_samples))

# 提取每个码元段的2UI长度信号
for i in range(num_segments):
    start_idx = i * samples_per_bit
    end_idx = start_idx + eye_samples
    if end_idx <= len(received_signal):
        eye_signal[i, :] = received_signal[start_idx:end_idx]

# 绘制眼图
plt.figure(figsize=(10, 6))
# 绘制所有码元段（叠加形成眼图）
for i in range(num_segments):
    plt.plot(np.linspace(-UI, UI, eye_samples) * 1e12,  # x轴：-UI~UI (ps)
             eye_signal[i, :], 
             color='blue', alpha=0.1)  # 透明度过低避免重叠过密

# 计算并标注眼高（Eye Height）：眼图最大-最小电压
eye_max = np.max(eye_signal)
eye_min = np.min(eye_signal)
eye_height = eye_max - eye_min
# 标注眼高
plt.annotate(f'Eye Height: {eye_height:.4f} V',
             xy=(0, (eye_max + eye_min)/2),
             xytext=(0, (eye_max + eye_min)/2 + 0.2),
             ha='center', fontsize=10,
             arrowprops=dict(arrowstyle='->', color='red'))

# 标注UI（Unit Interval）
plt.annotate(f'UI: {UI*1e12:.2f} ps',
             xy=(UI*1e12, eye_min - 0.1),
             xytext=(UI*1e12, eye_min - 0.3),
             ha='center', fontsize=10,
             arrowprops=dict(arrowstyle='->', color='green'))

# 图形美化（英文标签）
plt.xlabel('Time (ps)', fontsize=12)
plt.ylabel('Amplitude (V)', fontsize=12)
plt.title(f'Eye Diagram for Via Model', fontsize=14, fontweight='bold')
plt.grid(True, alpha=0.3)
plt.xlim(-UI*1e12 - 50, UI*1e12 + 50)  # x轴范围：-UI~UI ±50ps
plt.ylim(eye_min - 0.5, eye_max + 0.5)  # y轴适配信号范围

# 保存眼图（高清格式）
plt.tight_layout()
plt.savefig('eye_diagram_via.png', dpi=300, bbox_inches='tight')

print(f"\nsave eye diagram: eye_diagram_via.png")
print(f"eye height: {eye_height:.4f} V | UI: {UI*1e12:.2f} ps")