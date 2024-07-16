module bottem_die(
    input clk,
    input rst_n,
// <-> top die
    output icache_valid_o,
    output [31:0] icache_addr_o,
    input icache_valid_i,
    input [31:0] icache_dat_i,

    output dcache_valid_o,
    output [31:0] dcache_addr_o,
    output dcache_we_o,
    input dcache_valid_i,
    input [31:0] dcache_dat_i,
    output [31:0] dcache_dat_o
);

wire [31:0] pc, inst, dataadr, writedata, readdata;
wire mem_write, memread;

riscv_top riscv_top_u(
    .clk(clk),
    .reset(~rst_n),
    .pc(pc), 
    .instr(inst),
    .memwrite(memwrite),
    .aluout(dataadr),
    .writedata(writedata),
    .readdata(readdata),
    .memread(),
    .suspend()
);

l1i l1i_u(
    .pc(pc), 
    .inst(inst),
        // <-> l2 
    .valid_o(icache_valid_o),
    .l2_addr_o(icache_addr_o),
    .valid_i(icache_valid_i),
    .idat(icache_dat_i),

    .clk(clk),
    .rst_n(rst_n)
);

l1d l1d_u(
.addr(dataadr), 
.data_i(writedata),
.data_o(readdata),
.we_i(~memwrite),
    // <-> l2 
.valid_o(dcache_valid_o),
.l2_addr_o(dcache_addr_o),
.we_o(dcache_we_o),
.valid_i(dcache_valid_i),
.idat(dcache_dat_i),
.odat(dcache_dat_o),
.clk(clk),
.rst_n(rst_n)
);

endmodule

