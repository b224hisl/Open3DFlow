module top_die(
    // <-> soc
    input clk,
    input rst_n,
    output uart_tx,
    input uart_rx,
    // <-> bottem die
    input icache_valid_i,
    input [31:0] icache_addr_i,
    output icache_valid_o,
    output [31:0] icache_dat_o,

    input dcache_valid_i,
    input [31:0] dcache_addr_i,
    input dcache_we_i,
    output dcache_valid_o,
    output [31:0] dcache_dat_o,
    input [31:0] dcache_dat_i

);
wire arvalid, arready, awvalid, awready, rvalid, rready, wvalid, wready;
wire [31:0] ar, aw, r, w;

l2 l2u(
    .clk(clk),
    .rst_n(rst_n),
    // <-> i$
    .icache_valid_i(icache_valid_i),
    .icache_addr_i(icache_addr_i),
    .icache_valid_o(icache_valid_o),
    .icache_dat_o(icache_dat_o),
    // <-> d$
    .dcache_valid_i(dcache_valid_i),
    .dcache_addr_i(dcache_addr_i),
    .dcache_we_i(dcache_we_i),
    .dcache_valid_o(dcache_valid_o),
    .dcache_dat_o(dcache_dat_o),
    .dcache_dat_i(dcache_dat_i),
    // <-> memory
    // R
    .l2_req_if_arvalid(arvalid),
    .l2_req_if_arready(arready),
    .l2_req_if_ar(ar),
      // ewrq -> mem bus
      // AW 
    .l2_req_if_awvalid(awvalid),
    .l2_req_if_awready(awready),
    .l2_req_if_aw(aw),
      // W 
    .l2_req_if_wvalid(wvalid),
    .l2_req_if_wready(wready),
    .l2_req_if_w(w),

      // mem bus -> mlfb
      // R
    .l2_resp_if_rvalid(rvalid),
    .l2_resp_if_rready(rready),
    .l2_resp_if_r(r)
);

AXI4_UART uart_u(
    .i_s_axi_aclk      (clk),
    .i_s_axi_aresetn   (rst_n),
    .i_s_axi_awaddr    (aw),
    .i_s_axi_awprot    (),
    .i_s_axi_awvalid   (awvalid),
    .o_s_axi_awready   (awready),
    .i_s_axi_wdata     (w),
    .i_s_axi_wstrb     (),
    .i_s_axi_wvalid    (wvalid),
    .o_s_axi_wready    (wready),
    .o_s_axi_bresp     (),
    .o_s_axi_bvalid    (),
    .i_s_axi_bready    (),
    .i_s_axi_araddr    (ar),
    .i_s_axi_arprot    (),
    .i_s_axi_arvalid   (arvalid),
    .o_s_axi_arready   (arready),
    .o_s_axi_rdata     (r),
    .o_s_axi_rresp     (),
    .o_s_axi_rvalid    (rvalid),
    .i_s_axi_rready    (rready),
    .i_uart_rx         (uart_rx),
    .o_uart_tx (uart_tx)
);

endmodule