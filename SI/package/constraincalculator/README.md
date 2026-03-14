For constrain calculation
1. line width (stripe line for anti-interference)
input for calculation
    content     unit        default     symbol
----------------------------------------------------------------------
    characteristic impedance        ohm     50      Z0
(package vendor)
    metal thickness      um     15      t
    dielectric thickness        um      25      H
(material exploration)  
    dielectric constant     \       3.4     epsilon_r
(design)
    signal frequency    GHz      3.2    frequency

[Target]: line width  W  mm                              

2. wire length
input for calculation
    content     unit        default     symbol
----------------------------------------------------------------------
(use line width calculator)
    linewidth        mm      24500   W
    characteristic impedance        ohm     50      Z0
(material exploration)
    dielectric constant     \       3.4     epsilon_r
    dielectric loss tangent     \       0.002       tand
    metal conductivity      S/m     5.8e7       sigma 
(design)
    signal frequency    GHz      3.2    frequency
     
[Target]: Scanning insertion loss at different transmission distances 

3. line pitch
input for calculation
    

5. 


       