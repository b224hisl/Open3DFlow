module l1d(
    input [31:0] addr, 
    input [31:0] data_i,
    output [31:0] data_o,
    input we_i,
    // <-> l2 
    output valid_o,
    output [31:0] l2_addr_o,
    output we_o,
    input valid_i,
    input [31:0] idat,
    output [31:0] odat,
    input clk,
    input rst_n
);
wire refill_valid, write_tag_hit;
wire [31:0] dat_refill, dat_to_ram;
wire [5:0] set_idx;
wire [15:0] tag;
reg [63:0] line_valid;
wire miss;

assign write_tag_hit = we_i & ~miss;
assign set_idx = addr[5:0];
assign miss = (tag != addr[15:0]) & line_valid[set_idx];
assign refill_valid = valid_i;
assign valid_o = miss;
assign l2_addr_o = addr;
assign dat_to_ram = valid_i ? idat : 
                    write_tag_hit ? data_i : 32'b0;

// sram controller
mem_64_16_gf180 tag_ram(
	.clk(clk),
	.ce(1'b0),
	.we(refill_valid), //refill
    .addr(set_idx),
	.idat(addr[15:0]),
	.odat(tag)
);

mem_64_32_gf180 dat_ram(
	.clk(clk),
	.ce(1'b0),
	.we(refill_valid | write_tag_hit), //must wrong!
    .addr(set_idx),
	.idat(dat_to_ram),
	.odat(odat)
);

// how to juedge line valid?
// any req may be valid or invalid

always @(posedge clk or negedge rst_n) begin
    if(~rst_n) begin
        line_valid <= 63'b1;
    end 
//     else begin

//    end
end
endmodule