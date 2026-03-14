# via pi-type netlist
# three circle d D1 D2
# Calculate C1 C2 L1

# Configurable len 

import math

# 物理常数
epsilon_0 = 8.854187817e-12  # 真空介电常数，单位：F/m
mu_0 = 4 * math.pi * 1e-7    # 真空磁导率，单位：H/m
dielectric_thickness = 25e-6 # dielectric的厚度
metal_thickness = 15e-6 # metal 厚度
penetrate = 4 # 孔最大穿透几层 4 -（L1~L5）
d_m = 60e-6        # 孔内直径60um
D1_m = 90e-6       # 孔外直径90mm
eps_r = 3.6         # 基板的材料 （ABF 3.6）

def calculate_via_parameters(len_m, d_m, D1_m, eps_r):
    """
    计算过孔π型网络寄生参数
    
    参数：
    len_m: 过孔长度，单位：米
    d_m: 过孔直径，单位：米
    D1_m: 隔离焊盘直径，单位：米
    eps_r: 介质相对介电常数
    
    返回：
    L1: 过孔电感，单位：亨利
    C1, C2: 过孔两端寄生电容，单位：法拉
    """
    
    # 1. 计算电感L1（孤立直圆导线公式）
    # L1 = (μ₀/(2π)) * len * (ln(4*len/d) - 1)
    if d_m <= 0:
        raise ValueError("过孔直径必须大于0")
    if len_m <= d_m:
        raise ValueError("过孔长度应远大于直径")
    
    L1 = (mu_0 / (2 * math.pi)) * len_m * (math.log(4 * len_m / d_m) - 1)
    
    # 2. 计算电容C1和C2（圆柱电容模型）
    # 每个电容对应一半过孔长度：C = π * ε₀ * εᵣ * len / ln(D1/d)
    if D1_m <= d_m:
        raise ValueError("隔离焊盘直径必须大于过孔直径")
    
    C = math.pi * epsilon_0 * eps_r * len_m / math.log(D1_m / d_m)
    
    # 对称结构，C1 = C2 = C
    C1 = C
    C2 = C
    
    return L1, C1, C2

def print_results_with_units(L1, C1, C2):
    """格式化输出结果，使用合适的单位前缀"""
    
    # 电感单位转换
    if L1 >= 1e-6:
        L1_str = f"{L1*1e6:.3f} μH"
    elif L1 >= 1e-9:
        L1_str = f"{L1*1e9:.3f} nH"
    else:
        L1_str = f"{L1*1e12:.3f} pH"
    
    # 电容单位转换
    if C1 >= 1e-9:
        C1_str = f"{C1*1e9:.3f} nF"
    elif C1 >= 1e-12:
        C1_str = f"{C1*1e12:.3f} pF"
    else:
        C1_str = f"{C1*1e15:.3f} fF"
    
    print("过孔π型网络参数计算结果:")
    print(f"电感 L1: {L1_str}")
    print(f"电容 C1: {C1_str}")
    print(f"电容 C2: {C1_str}")  # C2 = C1
    
    # 同时返回数值（单位：亨利、法拉）
    return {
        "L1_H": L1,
        "C1_F": C1,
        "C2_F": C2
    }
    

# 示例：典型封装基板过孔参数
if __name__ == "__main__":
    # 示例参数（单位：米）
    # 假设过孔长度：0.5mm = 0.0005m
    # 过孔直径：0.1mm = 0.0001m
    # 隔离焊盘直径：0.3mm = 0.0003m
    # 介质相对介电常数（FR4材料）：4.5
    
    len_m = (dielectric_thickness + metal_thickness) * penetrate + metal_thickness
    
    try:
        # 计算参数
        L1, C1, C2 = calculate_via_parameters(len_m, d_m, D1_m, eps_r)
        
        # 格式化输出
        results = print_results_with_units(L1, C1, C2)
        
        # 计算谐振频率
        f_res = 1 / (2 * math.pi * math.sqrt(L1 * (C1 + C2) / 2))
        print(f"\n估计谐振频率: {f_res/1e9:.2f} GHz")
        
        # 计算特征阻抗（近似）
        Z0_approx = math.sqrt(L1 / ((C1 + C2) / 2))
        print(f"近似特征阻抗: {Z0_approx:.1f} Ω")
        
    except ValueError as e:
        print(f"参数错误: {e}")

