`timescale  1ns/1ps
module Uart_ctrl
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
    output       reg                 o_module_en               ,
    output       reg                 o_fifo_clr                ,
    output       reg     [31:0]      o_fre_cnt                 ,
    output       reg     [3:0]       o_uart_data_bit           ,
    output       reg     [2:0]       o_uart_parity_mode        ,
    output       reg     [2:0]       o_uart_stop_bit           ,
    output       wire    [7:0]       o_tx_data                 ,
    output       wire                o_tx_valid                ,
    input        wire    [8:0]       i_rx_data                 ,
    input        wire                o_rx_req                  ,
    input        wire    [15:0]      i_tx_fifo_wr_cnt          ,
    input        wire    [15:0]      i_rx_fifo_rd_cnt
);

    wire        [31:0]            w_ctrl_wr_addr        ;
    wire                          w_ctrl_wr_en          ;
    wire        [31:0]            w_ctrl_wr_data        ;
    wire        [3:0]             w_ctrl_wr_mask        ;
    wire        [31:0]            w_ctrl_rd_addr        ;
    reg         [31:0]            w_ctrl_rd_data        ;
    wire                          w_fifo_rstn           ;

    wire        [31:0]            w_reg_00_rd            ;
    wire        [31:0]            w_reg_01_rd            ;
    wire        [31:0]            w_reg_02_rd            ;
    wire        [31:0]            w_reg_03_rd            ;
    wire        [31:0]            w_reg_04_rd            ;
    wire        [31:0]            w_reg_05_rd            ;

localparam                SYS_FRE = 100_000_000;

/******************************************************************************\
Axi4_lite_slave interface
\******************************************************************************/
    // Uart_Axi4_lite_slave u_Uart_Axi4_lite_slave
    // (
    //     .i_s_axi_aclk            (i_s_axi_aclk              ),
    //     .i_s_axi_aresetn         (i_s_axi_aresetn           ),
    //     .i_s_axi_awaddr          (i_s_axi_awaddr            ),
    //     .i_s_axi_awprot          (i_s_axi_awprot            ),
    //     .i_s_axi_awvalid         (i_s_axi_awvalid           ),
    //     .o_s_axi_awready         (o_s_axi_awready           ),
    //     .i_s_axi_wdata           (i_s_axi_wdata             ),
    //     .i_s_axi_wstrb           (i_s_axi_wstrb             ),
    //     .i_s_axi_wvalid          (i_s_axi_wvalid            ),
    //     .o_s_axi_wready          (o_s_axi_wready            ),
    //     .o_s_axi_bresp           (o_s_axi_bresp             ),
    //     .o_s_axi_bvalid          (o_s_axi_bvalid            ),
    //     .i_s_axi_bready          (i_s_axi_bready            ),
    //     .i_s_axi_araddr          (i_s_axi_araddr            ),
    //     .i_s_axi_arprot          (i_s_axi_arprot            ),
    //     .i_s_axi_arvalid         (i_s_axi_arvalid           ),
    //     .o_s_axi_arready         (o_s_axi_arready           ),
    //     .o_s_axi_rdata           (o_s_axi_rdata             ),
    //     .o_s_axi_rresp           (o_s_axi_rresp             ),
    //     .o_s_axi_rvalid          (o_s_axi_rvalid            ),
    //     .i_s_axi_rready          (i_s_axi_rready            ),
    //     .o_ctrl_wr_addr          (w_ctrl_wr_addr            ),
    //     .o_ctrl_wr_en            (w_ctrl_wr_en              ),
    //     .o_ctrl_wr_data          (w_ctrl_wr_data            ),
    //     .o_ctrl_wr_mask          (w_ctrl_wr_mask            ),
    //     .o_ctrl_rd_addr          (w_ctrl_rd_addr            ),
    //     .i_ctrl_rd_data          (w_ctrl_rd_data            )
    // );
/******************************************************************************\
Register 0x00~0x03
\******************************************************************************/
    assign w_reg_00_rd = SYS_FRE;
/******************************************************************************\
Register 0x04~0x07
\******************************************************************************/
    always @ (posedge i_s_axi_aclk)
    begin
        if(~i_s_axi_aresetn)
        begin
            o_module_en     <= 'd0;
        end
        else if(w_ctrl_wr_en & (w_ctrl_wr_addr[7:2] == 6'h01) & w_ctrl_wr_mask[0])
        begin
            o_module_en     <= w_ctrl_wr_data[0];
        end
    end

    always @ (posedge i_s_axi_aclk)
    begin
        if(~i_s_axi_aresetn)
        begin
            o_fifo_clr         <= 'd0;
        end
        else if(w_ctrl_wr_en & (w_ctrl_wr_addr[7:2] == 6'h01) & w_ctrl_wr_mask[1])
        begin
            o_fifo_clr         <= w_ctrl_wr_data[8];
        end
        else
        begin
            o_fifo_clr      <= 'd0;
        end
    end

    always @ (posedge i_s_axi_aclk)
    begin
        if(~i_s_axi_aresetn)
        begin
            o_uart_data_bit        <= 'd0;
            o_uart_parity_mode     <= 'd0;
        end
        else if(w_ctrl_wr_en & (w_ctrl_wr_addr[7:2] == 6'h01) & w_ctrl_wr_mask[2])
        begin
            o_uart_data_bit        <= w_ctrl_wr_data[23:20];
            o_uart_parity_mode     <= w_ctrl_wr_data[18:16];
        end
    end

    always @ (posedge i_s_axi_aclk)
    begin
        if(~i_s_axi_aresetn)
        begin
            o_uart_stop_bit       <= 'd0;
        end
        else if(w_ctrl_wr_en & (w_ctrl_wr_addr[7:2] == 6'h01) & w_ctrl_wr_mask[3])
        begin
            o_uart_stop_bit       <= w_ctrl_wr_data[26:24];
        end
    end

    assign w_reg_01_rd = {{5'd0,o_uart_stop_bit},{o_uart_data_bit,1'b0,o_uart_parity_mode},8'd0,{7'd0,o_module_en}};
/******************************************************************************\
Register 0x08~0x0b
\******************************************************************************/
    always @ (posedge i_s_axi_aclk)
    begin
        if(~i_s_axi_aresetn)
        begin
            o_fre_cnt[7:0]       <= 'd0;
        end
        else if(w_ctrl_wr_en & (w_ctrl_wr_addr[7:2] == 6'h02) & w_ctrl_wr_mask[0])
        begin
            o_fre_cnt[7:0]       <= w_ctrl_wr_data[7:0];
        end
    end
    always @ (posedge i_s_axi_aclk)
    begin
        if(~i_s_axi_aresetn)
        begin
            o_fre_cnt[15:8]     <= 'd0;
        end
        else if(w_ctrl_wr_en & (w_ctrl_wr_addr[7:2] == 6'h02) & w_ctrl_wr_mask[1])
        begin
            o_fre_cnt[15:8]     <= w_ctrl_wr_data[15:8];
        end
    end
    always @ (posedge i_s_axi_aclk)
    begin
        if(~i_s_axi_aresetn)
        begin
            o_fre_cnt[23:16]     <= 'd0;
        end
        else if(w_ctrl_wr_en & (w_ctrl_wr_addr[7:2] == 6'h02) & w_ctrl_wr_mask[2])
        begin
            o_fre_cnt[23:16]     <= w_ctrl_wr_data[23:16];
        end
    end
    always @ (posedge i_s_axi_aclk)
    begin
        if(~i_s_axi_aresetn)
        begin
            o_fre_cnt[31:24]     <= 'd0;
        end
        else if(w_ctrl_wr_en & (w_ctrl_wr_addr[7:2] == 6'h02) & w_ctrl_wr_mask[3])
        begin
            o_fre_cnt[31:24]     <= w_ctrl_wr_data[31:24];
        end
    end

    assign w_reg_02_rd = o_fre_cnt;

/******************************************************************************\
Register 0x0c~0x0f
\******************************************************************************/
    assign o_tx_valid = (w_ctrl_wr_en & (w_ctrl_wr_addr[7:2] == 6'h03) & w_ctrl_wr_mask[0]);
    assign o_tx_data  = w_ctrl_wr_data[7:0];

/******************************************************************************\
Register 0x10~0x13
\******************************************************************************/
    assign o_rx_req = i_s_axi_arvalid & o_s_axi_arready & (i_s_axi_araddr[11:0] == 12'h010);
    assign w_reg_04_rd = {23'd0,i_rx_data};

/******************************************************************************\
缓存状态 0x14~0x17
\******************************************************************************/
    assign w_reg_05_rd = {i_tx_fifo_wr_cnt,i_rx_fifo_rd_cnt};
/******************************************************************************\
Read Register
\******************************************************************************/
    always @ (*)
    begin
        case(w_ctrl_rd_addr[7:2])
            6'h00    :    w_ctrl_rd_data = w_reg_00_rd        ;
            6'h01    :    w_ctrl_rd_data = w_reg_01_rd        ;
            6'h02    :    w_ctrl_rd_data = w_reg_02_rd        ;
            6'h04    :    w_ctrl_rd_data = w_reg_04_rd        ;
            6'h05    :    w_ctrl_rd_data = w_reg_05_rd        ;
            default    :    w_ctrl_rd_data = 32'h0000;
        endcase
    end

endmodule