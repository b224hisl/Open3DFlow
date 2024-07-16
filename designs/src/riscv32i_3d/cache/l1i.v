module l1i(
    input [31:0] pc, 
    output [31:0] inst,
    // <-> l2 
    output valid_o,
    output [31:0] l2_addr_o,
    input valid_i,
    input [31:0] idat,

    input clk,
    input rst_n
);
wire refill_valid, miss;
wire [5:0] set_idx;
wire [15:0] tag;
wire [31:0] refill_dat;


assign set_idx = pc[5:0]; // miss condition: blocking request, thus pc won't change
assign miss = tag != pc[15:0];
assign refill_valid = valid_i;
assign valid_o = ~miss;
assign l2_addr_o = pc;



// sram controller
mem_64_32_gf180 dat_ram(
	.clk(clk),
	.ce(1'b0),
	.we(refill_valid),
    .addr(set_idx),
	.idat(refill_dat),
	.odat(inst)
);

mem_64_16_gf180 tag_ram(
	.clk(clk),
	.ce(1'b0),
	.we(~refill_valid),
    .addr(set_idx),
	.idat(pc[15:0]),
	.odat(tag)
);

endmodule