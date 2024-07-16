import math

def cal(period):
    # 频率
    ns = 10**(-9)
    period = period * ns
    freq  = 1/period


    # 常数
    k = 1.38 * 10**(-32) # 玻尔兹曼常数
    T = 300 # 室温300K
    Na = 10**(21) # 受主掺杂浓度
    ni = 10**(16) #本征半导体电子浓度
    q=1.602*10**(-19) # 电子电荷
    kp = 1 # 临近效应（未考虑）

    # 尺寸
    um = 10**(-6)
    hTSV = 15 * um
    hsubstrate = 5 * um
    hunderfill = 5 * um
    hinsulator = hTSV
    hIMD = 5 * um
    hsi = 5 * um
    dTSV = 10 * um
    tox = 0.1 * um
    p = 20 * um

    # 材料特性
    pTSV = 1.72 * 10**(-8)
    uTSV = 1
    u0 = 4 * math.pi * 10**(-7)
    bTSV = 59.6 * 10**(6)


    # 电阻
    RdcTSV=pTSV * hTSV / (math.pi * (dTSV/2)**2) #pTSV为电阻率
    gTSV=1 / math.sqrt(math.pi * u0* uTSV * freq * bTSV) #g为趋肤深度，bTSV为电导率
    RacTSV=kp * pTSV * hTSV /(math.pi * dTSV * gTSV) #freqa
    RTSV = math.sqrt((RdcTSV**2) + (RacTSV**2))
    R_SK = RTSV/((freq)**2)


    # 电感
    LTSVex = (u0 * uTSV / math.pi) * math.log( p/dTSV + math.sqrt((p/dTSV)**2 - 1)) # p 是间距
    LTSV = hTSV/2 * LTSVex + RacTSV/(2 * math.pi * freq)

    # 电容与电感
    a = 2 * math.pi * 8.854 * (10**(-12)) * 3.9 * hinsulator
    b = math.log((dTSV/2 + tox) / (dTSV/2))
    Cinsulator = a / b
    # CTSV
    c = 2 * math.pi * 8.854 * (10**(-12)) * 11.9 * hsi
    tdepmax = math.sqrt(( 4 * 11.9 * k * T / (q**2 * Na)) * math.log(Na/ni))
    d = dTSV/2 + tox + tdepmax
    e = dTSV/2 + tox
    Cdepmin = c / math.log(d/e)
    CTSV = 1/Cinsulator + 1/Cdepmin
    # Csi
    f = math.pi * 8.854 * (10**(-12)) * 11.9 * hsubstrate
    h = p / (dTSV + 2 * tox)
    Csi = f / math.log(h + math.sqrt(h**2 - 1))
    # Gsi
    Gsi = Csi * (3.03 / (8.854 * (10**(-12)) * 11.9))
    Rsi = 1/Gsi
    # CIMD
    i = math.pi * 8.854 * (10**(-12)) * 3.9 * hIMD
    j = p / dTSV
    CIMD = i / math.log(j + math.sqrt(j**2 - 1))
    #Cunderfill
    l = math.pi * 8.854 * (10**(-12)) * 2.6 * hunderfill
    m = p / (dTSV + 2 * tox)
    Cunderfill = l/ math.log(m + math.sqrt(m**2 - 1))

    # print ("CIMD=",CIMD)
    # print ("Cinsulator=", Cinsulator)
    # print ("CRDL=",Cunderfill)
    # print ("CSi=",Csi)
    print ("LTSV=",LTSV)
    # print ("Rsi=", Rsi)
    print ("RTSV=",RTSV)
    
cal(40)

