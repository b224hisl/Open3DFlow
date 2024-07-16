
module core_without_dmem
(
  input  wire        clk,
  input  wire        reset,
  input  wire [31:0] instr,
  input  wire        valid,
  input  wire        valid_reg,
  output wire [7:0] writedata, //dmem_signal
  output wire [7:0] dataadr, //dmem_signal
  output wire        memwrite, 
  output wire        suspend, 
  output wire        ready,
  output wire [31:0] pc,
  // input wire [31:0] readdata,
  output wire [3:0] ce_mem, //dmem_signal
  output wire [3:0] we_mem, //dmem_signal
  input wire [7:0] inter_dmem0, //dmem_signal
  input wire [7:0] inter_dmem1, //dmem_signal
  input wire [7:0] inter_dmem2, //dmem_signal
  input wire [7:0] inter_dmem3 //dmem_signal
);
  wire [31:0] instr_int;
  wire [31:0] instr_out;
  wire        memread;
  wire        ready_intm; //seem to have no usage

  wire [31:0] readdata;
  wire [31:0] writedata_32;
  wire [31:0] dataadr_32;

  assign ready_intm = (reset) ? 1'b0 : ( (valid & ~valid_reg) ? 1'b1 : 1'b0 );
  assign ready = valid;
  assign writedata = writedata_32 [7:0];
  assign dataadr = dataadr_32 [7:0];

  riscv riscv (.clk(clk), .reset(reset),
               .pc(pc), .instr(instr_out),
               .memwrite(memwrite),
               .aluout(dataadr_32),
               .writedata(writedata_32),
               .readdata(readdata),
               .memread(memread),
               .suspend(suspend));
  ROM boot (.clk(clk), .en(~pc[31]), .address(pc[30:0]), .instr(instr_int));
  mux2 #(32) pcmux(.d0(instr),
                   .d1(instr_int),
                   .s(~pc[31]),
                   .y(instr_out));
 dmem_communicate dmem_communicate(.clk(clk), .r_w(memwrite), .we_mem(we_mem), .ce_mem(ce_mem), .mem_out(readdata), .mem_addr(dataadr_32), .inter_dmem0(inter_dmem0), .inter_dmem1(inter_dmem1), .inter_dmem2(inter_dmem2), .inter_dmem3(inter_dmem3));




endmodule

