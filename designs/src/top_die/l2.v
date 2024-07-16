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
    input [31:0] dcache_addr_i,
    input dcache_we_i,
    output dcache_valid_o,
    output [31:0] dcache_dat_o,
    input [31:0] dcache_dat_i,
    // <-> memory
    // R
    output l2_req_if_arvalid,
    input  l2_req_if_arready,
    output [31:0]  l2_req_if_ar,
      // ewrq -> mem bus
      // AW 
    output l2_req_if_awvalid,
    input  l2_req_if_awready,
    output [31:0]  l2_req_if_aw,
      // W 
    output l2_req_if_wvalid,
    input  l2_req_if_wready,
    output [31:0]   l2_req_if_w,

      // mem bus -> mlfb
      // R
    input  l2_resp_if_rvalid,
    output l2_resp_if_rready,
    input [31:0]    l2_resp_if_r
);

wire [5:0] s0_set_idx;
wire way_idx, s0_valid, cache_hit;
wire [15:0] tag [1:0];
reg [15:0] s1_req_addr;
wire [1:0] tag_hit;
reg [5:0] s1_set_idx;
reg s1_valid, refill_is_i, s1_is_dcache_w, s1_is_i, s1_is_d, refill_is_d;
wire [31:0] dat_ram_out [1:0];
wire[31:0] dat_to_dat_ram;
reg [63:0] line_valid [1:0];
wire [1:0] refill_valid;
reg [63:0] evict_id, refill_id;

reg [2:0] rw_state;
localparam IDLE = 3'b0;
localparam EVICT_AW = 3'b1;
localparam EVICT_W = 3'd2;
localparam AR = 3'd3;
localparam R = 3'd4;

genvar i;

generate
    for(i = 0; i < 2; i = i + 1)begin
        assign refill_valid[i] = (rw_state == R) && (refill_id[s1_set_idx] == i[0]);
    end
endgenerate

assign l2_resp_if_rready = 1'b1;

assign dat_to_dat_ram = refill_valid ? l2_resp_if_r : dcache_dat_i;

assign l2_req_if_arvalid = (rw_state == AR);
assign l2_req_if_ar = {15'b0, s1_req_addr};

assign l2_req_if_awvalid = (rw_state == EVICT_AW);
assign l2_req_if_aw = {15'b0, tag[evict_id[s1_set_idx]]};


// RW FSM


always@(posedge clk or negedge rst_n) begin
    if(~rst_n) begin
        rw_state <= IDLE;
        evict_id <= 64'b0;
        // line_valid <= {64{2'b0}};
        refill_id <= 64'b0;
    end else begin
        case(rw_state)
            IDLE: begin
                if(~cache_hit) begin
                    if(&line_valid[s1_set_idx]) begin
                        rw_state <= EVICT_AW; // all full
                    end else begin
                        refill_id[s1_set_idx] <= ~refill_id[s1_set_idx];//only work for initial phase
                        rw_state <= AR;
                    end
                end
            end
            EVICT_AW: begin
                if(l2_req_if_awvalid & l2_req_if_awready) begin
                    refill_id[s1_set_idx] <= evict_id[s1_set_idx];
                    rw_state <= EVICT_W;                 
                end
            end
            EVICT_W: begin
                if(l2_req_if_wvalid & l2_req_if_wready) begin
                    evict_id[s1_set_idx] <= ~evict_id[s1_set_idx]; // randomly select evict way
                    rw_state <= AR;
                end
            end
            AR: begin
                if(l2_req_if_arvalid & l2_req_if_arready) begin
                    rw_state <= R;
                end
            end
            R: begin
                if(l2_resp_if_rvalid & l2_resp_if_rready) begin
                    rw_state <= IDLE;
                    line_valid[refill_id[s1_set_idx]][s1_set_idx] <= 1'b1;
                end
            end
        endcase
    end
end

// sram ctrl 2-bank
generate // 2-way
for(i = 0; i < 2; i = i + 1) begin
    mem_64_16_gf180 tag_ram(
        .clk(clk),
        .ce(1'b0),
        .we(refill_valid[i]), //refill
        .addr(s0_set_idx),
        .idat(s1_req_addr), // blocking cache will hold this addr
        .odat(tag[i])
    );

    mem_64_32_gf180 dat_ram(
        .clk(clk),
        .ce(1'b0),
        .we(s1_is_dcache_w & tag_hit[i]),
        .addr(s0_set_idx),
        .idat(dat_to_dat_ram),
        .odat(dat_ram_out[i])
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
        s1_is_dcache_w <= 1'b0;
    end else begin
        if(icache_valid_i) begin
            s1_req_addr <= icache_addr_i[15:0];
        end else if (dcache_addr_i)begin
            s1_req_addr <= dcache_addr_i[15:0];
        end
        s1_set_idx <= s0_set_idx;
        s1_valid <= s0_valid;
        s1_is_i <= s0_is_i;
        s1_is_d <= s0_is_d;
        refill_is_i <= s1_is_i & ~cache_hit;
        refill_is_d <= s1_is_d & ~cache_hit;
        s1_is_dcache_w <= s0_is_d & dcache_we_i;
    end
end

// stage 1
generate
    for(i = 0; i < 2; i = i + 1) begin
        assign tag_hit[i] = (tag[i] == s1_req_addr);
    end
endgenerate
assign cache_hit = |tag_hit;

assign icache_valid_o = (cache_hit & s1_is_i) ||
                        refill_valid & refill_is_i;

assign dcache_valid_o = (cache_hit & s1_is_d) ||
                        refill_valid & refill_is_d;

assign select_dat = tag_hit[0] ? dat_ram_out[0] : dat_ram_out[1];

assign icache_dat_o = (cache_hit & s1_is_i) ? select_dat : 
                    (refill_valid & refill_is_i) ?  l2_resp_if_r : 31'b0;

assign dcache_dat_o = (cache_hit & s1_is_d) ? select_dat : 
                    (refill_valid & refill_is_d) ?  l2_resp_if_r : 31'b0;

// 


endmodule
 
