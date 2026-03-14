import numpy as np
import pandas as pd
import scipy.signal as sp_signal
import matplotlib.pyplot as plt
import skrf as rf
from scipy.interpolate import interp1d
import re

# ===================== 1. 工具函数：解析带单位数值 =====================
def parse_value_with_unit(val_str):
    val_str_clean = val_str.strip().replace(" ", "").lower()
    match = re.match(r'^([-+]?\d+\.?\d*e?[-+]?\d*)([a-z]+)?$', val_str_clean)
    if not match:
        return None
    num = float(match.group(1))
    unit = match.group(2) if match.group(2) else ''
    unit_map = {'nh':1e-9, 'pf':1e-12, '':1}
    unit_key = unit[:2] if len(unit)>=2 else unit
    return num * unit_map.get(unit_key, 1)

# ===================== 2. 解析IBIS文件 =====================
def parse_ibis_file(ibis_path):
    ibis_params = {
        "pkg": {"R":0.141, "L":1.348e-9, "C":0.479e-12},
        "pin": {"R":0.136, "L":1.274e-9, "C":0.457e-12},
        "C_comp": 0.327e-12
    }
    try:
        with open(ibis_path, 'r', encoding='utf-8') as f:
            lines = [line.strip().lower() for line in f if line.strip()]
        # 解析Package
        for line in lines:
            if "r_pkg" in line and "typ" in line:
                ibis_params["pkg"]["R"] = float(re.findall(r'\d+\.?\d*', line)[0])
            if "l_pkg" in line and "typ" in line:
                val = parse_value_with_unit(re.findall(r'\d+\.?\d*[a-z]*', line)[0])
                if val: ibis_params["pkg"]["L"] = val
            if "c_pkg" in line and "typ" in line:
                val = parse_value_with_unit(re.findall(r'\d+\.?\d*[a-z]*', line)[0])
                if val: ibis_params["pkg"]["C"] = val
        # 解析Pin
        pin_line = next((l for l in lines if "j4" in l and "ca0" in l), None)
        if pin_line:
            parts = re.findall(r'\d+\.?\d*[a-z]*', pin_line)
            if len(parts)>=3:
                ibis_params["pin"]["R"] = float(parts[-3])
                ibis_params["pin"]["L"] = parse_value_with_unit(parts[-2]) or 1.274e-9
                ibis_params["pin"]["C"] = parse_value_with_unit(parts[-1]) or 0.457e-12
        print("✅ IBIS文件解析成功")
    except Exception as e:
        print(f"⚠️ IBIS解析警告：{e}，使用默认值")
    return ibis_params

# ===================== 3. 加载S21数据 =====================
def load_s21_data(csv_path):
    df = pd.read_csv(csv_path).dropna()
    df = df[df["Frequency_GHz"]>0]
    if len(df)<2: raise ValueError("S21数据过少")
    # 构建S21插值函数（核心：直接返回插值函数，不构建Network）
    freq_ghz = df["Frequency_GHz"].values
    s21_mag = 10 ** (df["S21_Magnitude_dB"].values/20)
    s21_phase = np.deg2rad(df["S21_Phase_deg"].values)
    s21_complex = s21_mag * np.exp(1j*s21_phase)
    
    # 构建频率→S21的插值函数（覆盖0~8GHz）
    s21_interp = interp1d(
        freq_ghz*1e9, s21_complex,
        kind='linear', bounds_error=False, fill_value=0
    )
    return s21_interp

# ===================== 4. 生成PRBS信号 =====================
def generate_prbs_signal(bit_rate=3.2e9, sample_rate=32e9, duration=0.5e-6):
    # 生成PRBS-7信号（简化版，避免复杂逻辑）
    samples_per_bit = int(sample_rate / bit_rate)
    total_samples = int(duration * sample_rate)
    # 强制偶数采样数
    total_samples = total_samples if total_samples%2==0 else total_samples+1
    
    # 简单PRBS生成（固定周期，足够生成眼图)
    random = np.random.choice([0, 1], size=7000, p=[0.5, 0.5])
    prbs_seq = random[:total_samples//samples_per_bit]
    prbs_signal = np.repeat(prbs_seq, samples_per_bit)[:total_samples] * 1.1
    time = np.linspace(0, duration, total_samples)
    return time, prbs_signal

# ===================== 5. RLC滤波 =====================
def apply_rlc_filter(time, sig, r, l, c):
    sample_rate = 1/(time[1]-time[0])
    b, a = sp_signal.bilinear([1], [l*c, r*c, 1], fs=sample_rate)
    return sp_signal.filtfilt(b, a, sig)

# ===================== 6. 应用S21（彻底重构，避免FFT长度问题） =====================
def apply_s21_simple(time, sig, s21_interp, sample_rate):
    """
    简化版S21应用：仅对正频率插值，利用实信号FFT的共轭对称性自动处理
    """
    n = len(sig)
    freq = np.fft.fftfreq(n, 1/sample_rate)
    sig_fft = np.fft.fft(sig)
    
    # 仅对所有频率点插值S21（无需手动处理负频率）
    s21_all = s21_interp(np.abs(freq))  # 负频率取绝对值（共轭对称）
    
    # 频域相乘+逆FFT
    output_fft = sig_fft * s21_all
    output_sig = np.fft.ifft(output_fft).real
    return output_sig

# ===================== 7. 生成眼图 =====================
def save_eye_diagram(sig, sample_rate, bit_rate, save_path="eye_diagram.png"):
    samples_per_ui = int(sample_rate / bit_rate)
    if samples_per_ui == 0: raise ValueError("采样率<比特率")
    
    # 提取有效UI
    n_ui = len(sig) // samples_per_ui
    if n_ui < 100: raise ValueError("UI数量不足")
    sig_trim = sig[:n_ui*samples_per_ui].reshape(n_ui, samples_per_ui)
    
    # 绘制并保存眼图（仅眼图，无其他元素）
    plt.figure(figsize=(8,6), dpi=300)
    plt.plot(sig_trim.T, color='blue', alpha=0.1, linewidth=0.5)
    plt.xlabel("UI (Unit Interval)")
    plt.ylabel("Voltage (V)")
    plt.title("Eye Diagram at 3.2Gbps (Output Port 2)")
    plt.xticks(np.linspace(0, samples_per_ui,5), [-0.5,-0.25,0,0.25,0.5])
    plt.grid(alpha=0.3)
    plt.tight_layout()
    plt.savefig(save_path, bbox_inches='tight', pad_inches=0.1)
    plt.close()
    print(f"✅ 眼图已保存：{save_path}")

# ===================== 主函数 =====================
if __name__ == "__main__":
    # 配置路径
    IBIS_PATH = "ibis_CA.ibs"
    S21_PATH = "s21_data.csv"
    EYE_PATH = "ca_eye_diagram.png"
    
    try:
        # 1. 解析参数
        ibis_params = parse_ibis_file(IBIS_PATH)
        s21_interp = load_s21_data(S21_PATH)
        
        # 2. 生成PRBS信号
        sample_rate = 32e9
        time, prbs = generate_prbs_signal(3.2e9, sample_rate, 0.5e-6)
        print(f"📌 PRBS信号：{len(prbs)}采样点（偶数）")
        
        # 3. RLC滤波
        total_r = ibis_params["pkg"]["R"] + ibis_params["pin"]["R"]
        total_l = ibis_params["pkg"]["L"] + ibis_params["pin"]["L"]
        total_c = ibis_params["pkg"]["C"] + ibis_params["pin"]["C"] + ibis_params["C_comp"]
        filtered = apply_rlc_filter(time, prbs, 0, total_l, total_c)
        
        # 4. 应用S21（简化版，无长度问题）
        output = apply_s21_simple(time, prbs, s21_interp, sample_rate)
        
        # 5. 保存眼图
        save_eye_diagram(output, sample_rate, 3.2e9, EYE_PATH)
        
    except FileNotFoundError as e:
        print(f"❌ 文件不存在：{e}")
    except ValueError as e:
        print(f"❌ 数据错误：{e}")
    except Exception as e:
        print(f"❌ 运行错误：{e}")
        import traceback
        traceback.print_exc()