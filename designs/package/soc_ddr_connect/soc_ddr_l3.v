// L3上有DDR3.1的DQ和 0-4 , 2-1 CA
module soc_ddr ();

 wire DQ1_0;
 wire DQ1_1;
 wire DQ1_2;
 wire DQ1_3;
 wire DQ1_4;
 wire DQ1_5;
 wire DQ1_6;
 wire DQ1_7;

 wire DQ3_0;
 wire DQ3_1;
 wire DQ3_2;
 wire DQ3_3;
 wire DQ3_4;
 wire DQ3_5;
 wire DQ3_6;
 wire DQ3_7;


 ddr DDR1 (
  .C3(DQ1_0),
  .C9(DQ1_1),
  .B4(DQ1_2),
  .B8(DQ1_3),
  .E3(DQ1_4),
  .E9(DQ1_5),
  .E4(DQ1_6),
  .E8(DQ1_7),

  .J4(CA0_s),
  .J8(CA1_s),
  .M3(CA10_s),
  .M9(CA11_s),
  .M4(CA12_s),
  .M8(CA13_s),
  .K4(CA2_s),
  .K8(CA3_s),
  .J3(CA4_s),
  .J9(CA5_s),
  .K3(CA6_s),
  .K9(CA7_s),
  .L4(CA8_s),
  .L8(CA9_s)
 );

 ddr DDR2 (.J4(CA0_s),
    .J8(CA1_s),
    .M3(CA10_s),
    .M9(CA11_s),
    .M4(CA12_s),
    .M8(CA13_s),
    .K4(CA2_s),
    .K8(CA3_s),
    .J3(CA4_s),
    .J9(CA5_s),
    .K3(CA6_s),
    .K9(CA7_s),
    .L4(CA8_s),
    .L8(CA9_s));

 ddr DDR3 (
   .C3(DQ3_0),
   .C9(DQ3_1),
   .B4(DQ3_2),
   .B8(DQ3_3),
   .E3(DQ3_4),
   .E9(DQ3_5),
   .E4(DQ3_6),
   .E8(DQ3_7)
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
    .L8(CA9)
 );
    
 soc u_soc (
   .soc_108(CA0),
   .soc_115(CA1),
   .soc_122(CA10),
   .soc_124(CA11),
   .soc_125(CA12),
   .soc_126(CA13),
   .soc_112(CA2),
   .soc_114(CA3),
   .soc_113(CA4),
   .soc_116(CA5),
   .soc_117(CA6),
   .soc_120(CA7),
   .soc_121(CA8),
   .soc_123(CA9),

   .soc_72(DQ3_0),
   .soc_73(DQ3_1),
   .soc_74(DQ3_2),
   .soc_75(DQ3_3),
   .soc_80(DQ3_4),
   .soc_81(DQ3_5),
   .soc_82(DQ3_6),
   .soc_83(DQ3_7),

   .soc_48(DQ1_0),
   .soc_49(DQ1_1),
   .soc_50(DQ1_2),
   .soc_51(DQ1_3),
   .soc_56(DQ1_4),
   .soc_57(DQ1_5),
   .soc_58(DQ1_6),
   .soc_59(DQ1_7));
endmodule
