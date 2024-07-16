module l2(
    input clk,
    input rst_n,
    // <-> i$
    input icache_valid_i,
    input [31:0] icache_addr_i,
    output icache_valid_o,
    output [31:0] icache_dat_o,
    // <-> d$
    input dcache_valid_i,
    input [1:0] dcache_addr_i,
    input dcache_we_i,
    output dcache_valid_o,
    output [31:0] dcache_dat_o,
    input [31:0] dcache_dat_i,
    // <-> memory
    output logic              l2_req_if_arvalid,
    input  logic              l2_req_if_arready,
    output cache_mem_if_ar_t  l2_req_if_ar,
      // ewrq -> mem bus
      // AW 
    output logic              l2_req_if_awvalid,
    input  logic              l2_req_if_awready,
    output cache_mem_if_aw_t  l2_req_if_aw,
      // W 
    output logic              l2_req_if_wvalid,
    input  logic              l2_req_if_wready,
    output cache_mem_if_w_t   l2_req_if_w,
      // B
    input  logic              l2_resp_if_bvalid,
    output logic              l2_resp_if_bready,
    input  cache_mem_if_b_t   l2_resp_if_b,
      // mem bus -> mlfb
      // R
    input  logic              l2_resp_if_rvalid,
    output logic              l2_resp_if_rready,
    input cache_mem_if_r_t    l2_resp_if_r,
);

wire [5:0] s0_set_idx;
wire way_idx, s0_valid, cache_hit;
wire [15:0] tag [1:0];
reg [15:0] s1_req_addr;
wire [1:0] tag_hit;
reg [5:0] s1_set_idx;
reg s1_valid;




// sram ctrl 2-bank
genvar i;
generate // 2-way
for(int i = 0; i < 2; i++) begin
    mem_64_16_gf180 tag_ram(
        .clk(clk),
        .ce(1'b0),
        .we(refill_valid[i]), //refill
        .addr(s0_set_idx[i]),
        .idat(refill_tag[i]),
        .odat(tag[i])
    );

    mem_64_32_gf180 dat_ram(
        .clk(clk),
        .ce(1'b0),
        .we((refill_valid | dcache_we_i)[i]),
        .addr(s0_set_idx[i]),
        .idat(dat_to_ram[i]),
        .odat(odat[i])
    );
end
endgenerate

// crossbar
// priority: i$ > d$
// stage 0
assign s0_set_idx = icache_valid_i ? icache_addr_i[5:0] :dcache_addr_i[5:0];
assign s0_valid = icache_valid_i | dcache_valid_i;
assign s0_is_i = icache_valid_i;
assign s0_is_d = ~icache_valid_i & dcache_valid_i;

always@(posedge clk or negedge rst_n) begin
    if(~rst_n) begin
        s1_valid <= 1'b0;
        s1_req_addr <= 15'b0;
    end else begin
        if(icache_valid_i) begin
            s1_req_addr <= icache_addr_i[15:0];
        end else if (dcache_addr_i)begin
            s1_req_addr <= dcache_addr_i[15:0];
        end
        s1_valid <= s0_valid;
        s1_is_i <= s0_is_i;
        s1_is_d <= s0_is_d;
    end

end
// stage 1
genvar i;
generate
    for(int i = 0; i < 2; i = i + 1) begin
        assign tag_hit[i] = (tag[i] == s1_req_addr);
    end
endgenerate
assign cache_hit = |tag_hit;

assign icache_valid_o = (cache_hit & s1_is_i) ||
                        refill_valid & refill_is_i;
// 


endmodule
 
