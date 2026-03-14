import pandas as pd
import numpy as np
import matplotlib.pyplot as plt
from scipy import signal
from scipy.fft import fft, ifft, fftfreq, fftshift
import re

# ===================== 1. 配置核心参数 =====================
# 信号参数
PRBS_RATE_GHZ = 3.2          # PRBS信号速率(GHz)
PRBS_TYPE = 7                # PRBS-7序列
SAMPLING_RATE_GHZ = 8 * PRBS_RATE_GHZ  # 采样率(25.6GHz)
DURATION_NS = 100            # 仿真时长(ns)
EYE_SAMPLES_PER_BIT = 8      # 眼图每比特采样数

# 文件路径（请替换为你的实际文件路径）
IBIS_FILE_PATH = "ibis_CA.ibs"
S21_CSV_PATH = "s21_data.csv"
EYE_SAVE_PATH = "ca_port_eye_diagram.png"

# ===================== 2. 解析IBIS文件 =====================
def parse_ibis_file(file_path):
    """解析IBIS文件，提取关键参数"""
    ibis_params = {
        "R_pkg": {"typ": 0, "min": 0, "max": 0},
        "L_pkg": {"typ": 0, "min": 0, "max": 0},
        "C_pkg": {"typ": 0, "min": 0, "max": 0},
        "C_comp": {"typ": 0, "min": 0, "max": 0},
        "Vinl": 0, "Vinh": 0,
        "voltage_range": {"typ": 0, "min": 0, "max": 0},
        "temp_range": {"typ": 0, "min": 0, "max": 0}
    }
    
    with open(file_path, 'r', encoding='utf-8') as f:
        content = f.read()
    
    # 提取Package参数（处理nH/pF单位）
    pkg_pattern = r'R_pkg\s+([\d.]+)\s+([\d.]+)\s+([\d.]+)\s+L_pkg\s+([\d.]+)nH\s+([\d.]+)nH\s+([\d.]+)nH\s+C_pkg\s+([\d.]+)pF\s+([\d.]+)pF\s+([\d.]+)pF'
    pkg_match = re.search(pkg_pattern, content)
    if pkg_match:
        ibis_params["R_pkg"]["typ"] = float(pkg_match.group(1))
        ibis_params["R_pkg"]["min"] = float(pkg_match.group(2))
        ibis_params["R_pkg"]["max"] = float(pkg_match.group(3))
        ibis_params["L_pkg"]["typ"] = float(pkg_match.group(4)) * 1e-9  # 转H
        ibis_params["L_pkg"]["min"] = float(pkg_match.group(5)) * 1e-9
        ibis_params["L_pkg"]["max"] = float(pkg_match.group(6)) * 1e-9
        ibis_params["C_pkg"]["typ"] = float(pkg_match.group(7)) * 1e-12  # 转F
        ibis_params["C_pkg"]["min"] = float(pkg_match.group(8)) * 1e-12
        ibis_params["C_pkg"]["max"] = float(pkg_match.group(9)) * 1e-12
    
    # 提取C_comp参数
    c_comp_pattern = r'C_comp\s+([\d.]+)pF\s+([\d.]+)pF\s+([\d.]+)pF'
    c_comp_match = re.search(c_comp_pattern, content)
    if c_comp_match:
        ibis_params["C_comp"]["typ"] = float(c_comp_match.group(1)) * 1e-12
        ibis_params["C_comp"]["min"] = float(c_comp_match.group(2)) * 1e-12
        ibis_params["C_comp"]["max"] = float(c_comp_match.group(3)) * 1e-12
    
    # 提取Vinl/Vinh
    vin_pattern = r'Vinl\s+=\s+([\d.]+)V\s+Vinh\s+=\s+([\d.]+)V'
    vin_match = re.search(vin_pattern, content)
    if vin_match:
        ibis_params["Vinl"] = float(vin_match.group(1))
        ibis_params["Vinh"] = float(vin_match.group(2))
    
    # 提取电压/温度范围
    volt_range_pattern = r'\[Voltage Range\]\s+([\d.]+)V\s+([\d.]+)V\s+([\d.]+)V'
    volt_match = re.search(volt_range_pattern, content)
    if volt_match:
        ibis_params["voltage_range"]["typ"] = float(volt_match.group(1))
        ibis_params["voltage_range"]["min"] = float(volt_match.group(2))
        ibis_params["voltage_range"]["max"] = float(volt_match.group(3))
    
    return ibis_params

# 执行IBIS解析
ibis_params = parse_ibis_file(IBIS_FILE_PATH)
print("IBIS参数解析完成，核心参数(typ)：")
print(f"封装电阻: {ibis_params['R_pkg']['typ']} Ω")
print(f"封装电感: {ibis_params['L_pkg']['typ']*1e9} nH")
print(f"封装电容: {ibis_params['C_pkg']['typ']*1e12} pF")
print(f"核心电容: {ibis_params['C_comp']['typ']*1e12} pF")

# ===================== 3. 读取并处理S21数据 =====================
def process_s21_data(csv_path, sampling_rate):
    """读取S21 CSV，转换为频域响应并生成时域脉冲响应"""
    # 读取数据
    df = pd.read_csv(csv_path)
    freq_ghz = df["Frequency_GHz"].values
    s21_mag_dB = df["S21_Magnitude_dB"].values
    s21_phase_deg = df["S21_Phase_deg"].values
    
    # 转换为线性幅度和弧度相位
    s21_mag_linear = 10 ** (s21_mag_dB / 20)
    s21_phase_rad = np.deg2rad(s21_phase_deg)
    
    # 构造复数值S21
    s21_complex = s21_mag_linear * np.exp(1j * s21_phase_rad)
    
    # 频率轴转换为Hz
    freq_hz = freq_ghz * 1e9
    
    # 补零到采样率对应的频率分辨率（保证逆FFT的时域长度）
    max_freq = sampling_rate / 2  # 奈奎斯特频率
    n_points = int(np.ceil(max_freq / (freq_hz[1] - freq_hz[0])))
    freq_hz_padded = np.linspace(0, max_freq, n_points)
    s21_complex_padded = np.interp(freq_hz_padded, freq_hz, s21_complex)
    
    # 构造双边谱（满足共轭对称性）
    s21_complex_full = np.concatenate([
        s21_complex_padded,
        np.conj(s21_complex_padded[1:-1][::-1])
    ])
    
    # 逆FFT得到时域脉冲响应
    s21_impulse = ifft(fftshift(s21_complex_full))
    s21_impulse = np.real(s21_impulse)  # 取实部
    
    # 归一化脉冲响应
    s21_impulse /= np.max(np.abs(s21_impulse))
    
    return s21_impulse, freq_hz_padded

# 处理S21数据
s21_impulse, freq_padded = process_s21_data(S21_CSV_PATH, SAMPLING_RATE_GHZ * 1e9)
print("S21数据处理完成，脉冲响应长度:", len(s21_impulse))

# ===================== 4. 生成3.2GHz PRBS信号 =====================
def generate_prbs(prbs_type, bit_rate, sampling_rate, duration_ns):
    """生成PRBS信号
    prbs_type: PRBS-n，如7/9/15/31
    bit_rate: 比特率(GHz)
    sampling_rate: 采样率(GHz)
    duration_ns: 时长(ns)
    """
    # 计算参数
    bit_period_ns = 1 / bit_rate  # 每比特时长(ns)
    samples_per_bit = int(sampling_rate / bit_rate)
    total_samples = int(duration_ns * sampling_rate)
    
    # 生成PRBS序列（基于线性反馈移位寄存器）
    if prbs_type == 7:
        taps = [7, 6]  # PRBS-7的反馈抽头
        register = np.ones(7, dtype=int)  # 初始寄存器状态
    elif prbs_type == 15:
        taps = [15, 14]
        register = np.ones(15, dtype=int)
    else:
        raise ValueError("仅支持PRBS-7/15，如需其他类型请扩展taps")
    
    # 生成PRBS比特流
    prbs_bits = []
    for _ in range(total_samples // samples_per_bit + 1):
        # 计算反馈位
        feedback = register[taps[0]-1] ^ register[taps[1]-1]
        prbs_bits.append(register[-1])
        # 移位寄存器
        register = np.roll(register, 1)
        register[0] = feedback
    
    # 扩展为采样点（每比特对应samples_per_bit个采样）
    prbs_signal = np.repeat(prbs_bits, samples_per_bit)[:total_samples]
    
    # 转换为电压信号（基于IBIS的Vinl/Vinh）
    prbs_voltage = ibis_params["Vinl"] + (ibis_params["Vinh"] - ibis_params["Vinl"]) * prbs_signal
    
    # 添加随机抖动（模拟实际信号）
    jitter = np.random.normal(0, 0.01, total_samples)
    prbs_voltage += jitter
    
    return prbs_voltage, samples_per_bit

# 生成PRBS信号
prbs_signal, samples_per_bit = generate_prbs(
    PRBS_TYPE, PRBS_RATE_GHZ, SAMPLING_RATE_GHZ, DURATION_NS
)
print("PRBS信号生成完成，信号长度:", len(prbs_signal))

# ===================== 5. IBIS驱动等效响应（RLC滤波） =====================
def ibis_driver_filter(signal, sampling_rate, ibis_params):
    """用RLC滤波器模拟IBIS驱动的时域响应"""
    fs = sampling_rate * 1e9  # 采样率转Hz
    # 提取典型值构建RLC电路
    R = ibis_params["R_pkg"]["typ"]
    L = ibis_params["L_pkg"]["typ"]
    C_total = ibis_params["C_pkg"]["typ"] + ibis_params["C_comp"]["typ"]
    
    # 计算RLC电路的传递函数（二阶系统）
    # 传递函数：H(s) = 1/(LC s² + RC s + 1)
    numerator = [1]
    denominator = [L*C_total, R*C_total, 1]
    
    # 转换为数字滤波器（双线性变换）
    b, a = signal.bilinear(numerator, denominator, fs)
    
    # 滤波（模拟信号通过IBIS驱动）
    filtered_signal = signal.lfilter(b, a, signal)
    
    return filtered_signal

# PRBS信号通过IBIS驱动
ibis_output = ibis_driver_filter(
    prbs_signal, SAMPLING_RATE_GHZ, ibis_params
)
print("IBIS驱动仿真完成")

# ===================== 6. 信号通过S21网络（卷积） =====================
# 卷积实现信号通过S21网络（注意截断避免边缘效应）
s21_output = signal.convolve(ibis_output, s21_impulse, mode='same')
print("S21网络传输完成")

# ===================== 7. 生成并保存眼图 =====================
def plot_eye_diagram(signal, samples_per_bit, save_path, bit_rate_ghz):
    """绘制并保存眼图"""
    # 计算眼图的比特数和采样数
    num_bits = len(signal) // samples_per_bit
    eye_signal = signal[:num_bits * samples_per_bit].reshape(-1, samples_per_bit).T
    
    # 创建画布
    plt.figure(figsize=(10, 6))
    plt.plot(eye_signal, color='blue', alpha=0.1)  # 绘制多比特叠加
    plt.grid(True, linestyle='--', alpha=0.7)
    
    # 设置标签和标题
    plt.xlabel(f'Samples per Bit (Bit Rate: {bit_rate_ghz} GHz)')
    plt.ylabel('Voltage (V)')
    plt.title('CA Port Eye Diagram (PRBS -> IBIS -> S21)')
    
    # 调整x轴刻度为比特周期
    plt.xticks(
        [0, samples_per_bit//2, samples_per_bit-1],
        ['0', 'T/2', 'T']
    )
    
    # 保存眼图
    plt.tight_layout()
    plt.savefig(save_path, dpi=300, bbox_inches='tight')
    plt.close()
    print(f"眼图已保存至: {save_path}")

# 生成并保存眼图
plot_eye_diagram(
    s21_output, 
    EYE_SAMPLES_PER_BIT, 
    EYE_SAVE_PATH, 
    PRBS_RATE_GHZ
)