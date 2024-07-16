module AXI4_UART
(
    input        wire                i_s_axi_aclk              ,
    input        wire                i_s_axi_aresetn           ,
    input        wire    [31:0]      i_s_axi_awaddr            ,
    input        wire    [2:0]       i_s_axi_awprot            ,
    input        wire                i_s_axi_awvalid           ,
    output       wire                o_s_axi_awready           ,
    input        wire    [31:0]      i_s_axi_wdata             ,
    input        wire    [3:0]       i_s_axi_wstrb             ,
    input        wire                i_s_axi_wvalid            ,
    output       wire                o_s_axi_wready            ,
    output       wire     [1:0]      o_s_axi_bresp             ,
    output       wire                o_s_axi_bvalid            ,
    input        wire                i_s_axi_bready            ,
    input        wire    [31:0]      i_s_axi_araddr            ,
    input        wire    [2:0]       i_s_axi_arprot            ,
    input        wire                i_s_axi_arvalid           ,
    output       wire                o_s_axi_arready           ,
    output       wire    [31:0]      o_s_axi_rdata             ,
    output       wire    [1:0]       o_s_axi_rresp             ,
    output       wire                o_s_axi_rvalid            ,
    input        wire                i_s_axi_rready            ,
    input        wire                i_uart_rx                 ,
    output       wire                o_uart_tx
);

    wire                              w_module_en              ;
    wire                [31:0]        w_fre_cnt                ;
    wire                [3:0]         w_uart_data_bit          ;
    wire                [2:0]         w_uart_parity_mode       ;
    wire                [2:0]         w_uart_stop_bit          ;
    wire                [7:0]         w_tx_fifo_din            ;
    wire                              w_tx_fifo_wr             ;
    wire                [8:0]         w_rx_fifo_dout           ;
    wire                              w_rx_fifo_rd             ;
    wire                [15:0]        w_uart_wr_cnt            ;
    wire                [15:0]        w_uart_rd_cnt            ;
    wire                              w_fifo_rest              ;
    wire                              w_fifo_clr               ;
    wire                [7:0]         w_tx_data                ;
    wire                              w_tx_valid               ;
    wire                              w_tx_req                 ;
    wire                [8:0]         w_rx_data                ;
    wire                              w_rx_valid               ;
    wire                              w_tx_fifo_empty          ;

/******************************************************************************\
Uart control
\******************************************************************************/
    Uart_ctrl u_Uart_ctrl
    (
        .i_s_axi_aclk            (i_s_axi_aclk             ),
        .i_s_axi_aresetn         (i_s_axi_aresetn          ),
        .i_s_axi_awaddr          (i_s_axi_awaddr           ),
        .i_s_axi_awprot          (i_s_axi_awprot           ),
        .i_s_axi_awvalid         (i_s_axi_awvalid          ),
        .o_s_axi_awready         (o_s_axi_awready          ),
        .i_s_axi_wdata           (i_s_axi_wdata            ),
        .i_s_axi_wstrb           (i_s_axi_wstrb            ),
        .i_s_axi_wvalid          (i_s_axi_wvalid           ),
        .o_s_axi_wready          (o_s_axi_wready           ),
        .o_s_axi_bresp           (o_s_axi_bresp            ),
        .o_s_axi_bvalid          (o_s_axi_bvalid           ),
        .i_s_axi_bready          (i_s_axi_bready           ),
        .i_s_axi_araddr          (i_s_axi_araddr           ),
        .i_s_axi_arprot          (i_s_axi_arprot           ),
        .i_s_axi_arvalid         (i_s_axi_arvalid          ),
        .o_s_axi_arready         (o_s_axi_arready          ),
        .o_s_axi_rdata           (o_s_axi_rdata            ),
        .o_s_axi_rresp           (o_s_axi_rresp            ),
        .o_s_axi_rvalid          (o_s_axi_rvalid           ),
        .i_s_axi_rready          (i_s_axi_rready           ),
        .o_module_en             (w_module_en              ),
        .o_fifo_clr              (w_fifo_clr               ),
        .o_fre_cnt               (w_fre_cnt                ),
        .o_uart_data_bit         (w_uart_data_bit          ),
        .o_uart_parity_mode      (w_uart_parity_mode       ),
        .o_uart_stop_bit         (w_uart_stop_bit          ),
        .o_tx_data               (w_tx_fifo_din            ),
        .o_tx_valid              (w_tx_fifo_wr             ),
        .i_rx_data               (w_rx_fifo_dout           ),
        .o_rx_req                (w_rx_fifo_rd             ),
        .i_tx_fifo_wr_cnt        (w_uart_wr_cnt            ),
        .i_rx_fifo_rd_cnt        (w_uart_rd_cnt            )

    );

    assign w_fifo_rest = w_fifo_clr & (~i_s_axi_aresetn);
/******************************************************************************\
Uart tx
\******************************************************************************/
    Uart_tx u_Uart_tx
    (
        .i_sys_clk                (i_s_axi_aclk             ),
        .i_sys_rstn               (i_s_axi_aresetn & w_module_en),
        .i_fre_cnt                (w_fre_cnt                ),
        .i_tx_data_bit            (w_uart_data_bit          ),
        .i_parity_mode            (w_uart_parity_mode       ),
        .i_stop_bit               (w_uart_stop_bit          ),
        .i_tx_data                (w_tx_data                ),
        .i_tx_valid               (w_tx_valid               ),
        .o_tx_req                 (w_tx_req                 ),
        .o_uart_tx                (o_uart_tx                )
    );

/******************************************************************************\
Uart rx
\******************************************************************************/
    Uart_rx u_Uart_rx
    (
        .i_sys_clk                (i_s_axi_aclk             ),
        .i_sys_rstn               (i_s_axi_aresetn & w_module_en),
        .i_fre_cnt                (w_fre_cnt                ),
        .i_rx_data_bit            (w_uart_data_bit          ),
        .i_parity_mode            (w_uart_parity_mode[2]    ),
        .i_stop_bit               (w_uart_stop_bit          ),
        .o_rx_data                (w_rx_data                ),
        .o_rx_valid               (w_rx_valid               ),
        .i_uart_rx                (i_uart_rx                )
    );
/******************************************************************************\
Uart tx fifo
\******************************************************************************/
synch_fifo #(
    .FIFO_PTR(4),
    .FIFO_WIDTH(8),
    .FIFO_DEPTH(10)        
) tx_fifo (
    .clk         (i_s_axi_aclk)    ,
    .rst_n       (~w_fifo_rest)    ,
    .write_en    (w_tx_fifo_wr)    ,
    .write_data  (w_tx_fifo_din)    ,
    .read_en     (w_tx_req)    ,
    .read_data   (w_tx_data)    ,
    .full        ()    ,
    .empty       (w_tx_fifo_empty)    ,
    .room_avail  ()    ,
    .data_avail  (w_uart_wr_cnt)
);

assign w_tx_valid = ~w_tx_fifo_empty;
/******************************************************************************\
Uart rx fifo
\******************************************************************************/
 synch_fifo #(
    .FIFO_PTR(4),
    .FIFO_WIDTH(9),
    .FIFO_DEPTH(10)        
) rx_fifo (
    .clk         (i_s_axi_aclk)    ,
    .rst_n       (~w_fifo_rest)    ,
    .write_en    (w_rx_valid)    ,
    .write_data  (w_rx_data)    ,
    .read_en     (w_rx_fifo_rd)    ,
    .read_data   (w_rx_fifo_dout)    ,
    .full        ()    ,
    .empty       ()    ,
    .room_avail  ()    ,
    .data_avail  (w_uart_rd_cnt)
);

endmodule