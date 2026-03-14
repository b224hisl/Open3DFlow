// L5上有DDR2.4的DQ和 4-3-2 CA
module soc_ddr ();

 wire DQ2_0;
 wire DQ2_1;
 wire DQ2_2;
 wire DQ2_3;
 wire DQ2_4;
 wire DQ2_5;
 wire DQ2_6;
 wire DQ2_7;

 wire DQ4_0;
 wire DQ4_1;
 wire DQ4_2;
 wire DQ4_3;
 wire DQ4_4;
 wire DQ4_5;
 wire DQ4_6;
 wire DQ4_7;

 ddr DDR1 (
 );

 ddr DDR2 (.C3(DQ2_0),
    .C9(DQ2_1),
    .B4(DQ2_2),
    .B8(DQ2_3),
    .E3(DQ2_4),
    .E9(DQ2_5),
    .E4(DQ2_6),
    .E8(DQ2_7),
    
    .J4(CA0),
    .J8(CA1),
    .M3(CA10),
    .M9(CA11),
    .M4(CA12),
    .M8(CA13),
    .K4(CA2),
    .K8(CA3),
    .J3(CA4),
    .J9(CA5),
    .K3(CA6),
    .K9(CA7),
    .L4(CA8),
    .L8(CA9));

 ddr DDR3 (
    .J4(CA0),
    .J8(CA1),
    .M3(CA10),
    .M9(CA11),
    .M4(CA12),
    .M8(CA13),
    .K4(CA2),
    .K8(CA3),
    .J3(CA4),
    .J9(CA5),
    .K3(CA6),
    .K9(CA7),
    .L4(CA8),
    .L8(CA9)
 );

 ddr DDR4 (
    .J4(CA0),
    .J8(CA1),
    .M3(CA10),
    .M9(CA11),
    .M4(CA12),
    .M8(CA13),
    .K4(CA2),
    .K8(CA3),
    .J3(CA4),
    .J9(CA5),
    .K3(CA6),
    .K9(CA7),
    .L4(CA8),
    .L8(CA9),

    .C3(DQ4_0),
    .C9(DQ4_1),
    .B4(DQ4_2),
    .B8(DQ4_3),
    .E3(DQ4_4),
    .E9(DQ4_5),
    .E4(DQ4_6),
    .E8(DQ4_7));
    
 soc u_soc (
    .soc_60(DQ2_0),
    .soc_61(DQ2_1),
    .soc_62(DQ2_2),
    .soc_63(DQ2_3),
    .soc_68(DQ2_4),
    .soc_69(DQ2_5),
    .soc_70(DQ2_6),
    .soc_71(DQ2_7),

    .soc_84(DQ4_0),
    .soc_85(DQ4_1),
    .soc_86(DQ4_2),
    .soc_87(DQ4_3),
    .soc_92(DQ4_4),
    .soc_93(DQ4_5),
    .soc_94(DQ4_6),
    .soc_95(DQ4_7));
endmodule
