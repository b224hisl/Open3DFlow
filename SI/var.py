import math
from cal import cal
import matplotlib.pyplot as plt  

                                         # 80ns   20ns 12.5   5   1  0.5 0.2 
periods = [80, 20, 12.5, 5, 1, 0.5, 0.2] # 12.5M  50M  80M  200M  1G  2G  5G

for i, label in enumerate(['CIMD', 'Cinsulator', 'Cunderfill', 'Csi', 'LTSV', 'Rsi', 'RTSV']):  
    values = [cal(p)[i] for p in periods]  # 使用列表推导式计算每个period对应的值 
    print (i, label)
    print (values)
    plt.figure()  # 创建一个新的图形窗口  
    plt.plot(periods, values, marker='o')  # 绘制图形，并用点标记每个数据点  
    plt.title(f'Period vs {label}')  # 设置图形标题  
    plt.xlabel('Period(ns)')  # 设置x轴标签  
    plt.ylabel(label.upper())  # 设置y轴标签  
    plt.grid(True)  # 显示网格线  
    plt.savefig(f'{label}.png')  