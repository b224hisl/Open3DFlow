`timescale  1ns/1ps
module Uart_rx
(
    input                            i_sys_clk        ,
    input                            i_sys_rstn       ,

    input            [31:0]          i_fre_cnt        ,
    input            [3:0]           i_rx_data_bit    ,
    input                            i_parity_mode    ,
    input            [2:0]           i_stop_bit       ,
    output           [8:0]           o_rx_data        ,
    output                           o_rx_valid       ,
    input                            i_uart_rx

);
    localparam                S_IDLE         = 6'h01;
    localparam                S_START        = 6'h02;
    localparam                S_DATA         = 6'h04;
    localparam                S_PARITY       = 6'h08;
    localparam                S_STOP         = 6'h10;
    localparam                S_END          = 6'h20;

    reg                [31:0]           r_fre_cnt        ;
    reg                [3:0]            r_rx_data_bit    ;
    reg                                 r_parity_mode    ;
    reg                [2:0]            r_stop_bit       ;
    reg                [2:0]            r_uart_rx        ;
    reg                [31:0]           r_fre_sum        ;
    reg                                 r_rx_enable      ;
    reg                [1:0]            r_baud_fre       ;
    reg                [5:0]            r_current_state  ;
    reg                [5:0]            r_next_state     ;
    reg                [3:0]            r_cnt_rx_bit     ;
    reg                [7:0]            r_rx_data        ;
    reg                [7:0]            r_rx_data1       ;
    reg                                 r_cnt_parity_bit ;
    reg                                 r_parity_er      ;
    reg                                 r_parity_er1     ;
    reg                [2:0]            r_cnt_stop_bit   ;

    wire                            w_uart_rx_pos      ;
    wire                            w_uart_rx_neg      ;
    wire                            w_data_sample_en   ;
    wire                            w_data_sample_end  ;
    wire                            w_parity_sample_en ;
    wire                            w_parity_sample_end;
    wire                            w_stop_sample_en   ;
    wire                            w_stop_sample_end  ;
/******************************************************************************\
Synchronous signal
\******************************************************************************/
    always@(posedge i_sys_clk)
    begin
        if(~i_sys_rstn)
        begin
            r_fre_cnt         <= 'd0;
            r_rx_data_bit     <= 'd0;
            r_parity_mode     <= 'd0;
            r_stop_bit        <= 'd0;
        end
        else
        begin
            r_fre_cnt         <= i_fre_cnt    ;
            r_rx_data_bit     <= i_rx_data_bit;
            r_parity_mode     <= i_parity_mode;
            r_stop_bit        <= i_stop_bit    ;
        end
    end

    always@(posedge i_sys_clk)
    begin
        if(~i_sys_rstn)
        begin
            r_uart_rx <= 'd0;
        end
        else
        begin
            r_uart_rx <= {r_uart_rx[1:0],i_uart_rx};
        end
    end

    assign w_uart_rx_pos = ~r_uart_rx[2] & r_uart_rx[1];
    assign w_uart_rx_neg = ~r_uart_rx[1] & r_uart_rx[2];

/******************************************************************************\
Generate sample baud rate signal
\******************************************************************************/
    always@(posedge i_sys_clk)
    begin
        if(~i_sys_rstn)
        begin
            r_fre_sum <= 'd0;
        end
        else if(r_rx_enable)
        begin
            r_fre_sum <= r_fre_sum + r_fre_cnt;
        end
    end
    always@(posedge i_sys_clk)
    begin
        r_baud_fre <= {r_baud_fre[0],r_fre_sum[31]};
    end

    assign w_baud_pos = ~r_baud_fre[1] & r_baud_fre[0];
    assign w_baud_neg = ~r_baud_fre[0] & r_baud_fre[1];

    always@(*)
    begin
        case(r_current_state)
            S_IDLE: r_rx_enable <= 'd0;
            S_END : r_rx_enable <= 'd0;
            default:r_rx_enable <= 1'b1;
        endcase
    end

/******************************************************************************\
State machine
\******************************************************************************/
    always@(posedge i_sys_clk)
    begin
        if(~i_sys_rstn)
        begin
            r_current_state <= S_IDLE;
        end
        else
        begin
            r_current_state <= r_next_state;
        end
    end

    always@(*)
    begin
        r_next_state <= 'd1;
        case(r_current_state)
            S_IDLE:
                    begin
                        if(w_uart_rx_neg)
                        begin
                            r_next_state <= S_START;
                        end
                        else
                        begin
                            r_next_state <= S_IDLE;
                        end
                    end
            S_START:
                    begin
                        if(w_baud_pos & (r_uart_rx[2] == 1'b0))
                        begin
                            r_next_state <= S_DATA;
                        end
                        else if(w_baud_pos & (r_uart_rx[2] == 1'b1))
                        begin
                            r_next_state <= S_IDLE;
                        end
                        else
                        begin
                            r_next_state <= S_START;
                        end
                    end
            S_DATA:
                    begin
                        if(w_data_sample_end)
                        begin
                            if(r_parity_mode)
                            begin
                                r_next_state <= S_STOP;
                            end
                            else
                            begin
                                r_next_state <= S_PARITY;
                            end
                        end
                        else
                        begin
                            r_next_state <= S_DATA;
                        end
                    end
            S_PARITY:
                    begin
                        if(w_parity_sample_end)
                        begin
                            r_next_state <= S_STOP;
                        end
                        else
                        begin
                            r_next_state <= S_PARITY;
                        end
                    end
            S_STOP:
                    begin
                        if(w_stop_sample_end)
                        begin
                            r_next_state <= S_END;
                        end
                        else
                        begin
                            r_next_state <= S_STOP;
                        end
                    end
            S_END:
                    begin
                        r_next_state <= S_IDLE;
                    end
            default: r_next_state <= S_IDLE;
        endcase
    end
/******************************************************************************\
Uart rx data sample
\******************************************************************************/
    assign w_data_sample_en = (r_current_state == S_DATA) && w_baud_pos;
    assign w_data_sample_end = (r_current_state == S_DATA) && (r_cnt_rx_bit == r_rx_data_bit);

    always@(posedge i_sys_clk)
    begin
        if(~i_sys_rstn | w_data_sample_end)
        begin
            r_cnt_rx_bit <= 'd0;
        end
        else if(w_data_sample_en)
        begin
            r_cnt_rx_bit <= r_cnt_rx_bit + 1'b1;
        end
    end

    always@(posedge i_sys_clk)
    begin
        if(~i_sys_rstn | w_data_sample_end)
        begin
            r_rx_data <= 'd0;
        end
        else if(w_data_sample_en)
        begin
            r_rx_data <= {r_uart_rx[2],r_rx_data[7:1]};
        end
    end

    always@(posedge i_sys_clk)
    begin
        if(~i_sys_rstn)
        begin
            r_rx_data1 <= 'd0;
        end
        else if(w_data_sample_end)
        begin
            r_rx_data1 <= r_rx_data;
        end
    end

/******************************************************************************\
Uart rx parity sample
\******************************************************************************/
    assign w_parity_sample_en  = (r_current_state == S_PARITY) && w_baud_pos;
    assign w_parity_sample_end = (r_current_state == S_PARITY) && (r_cnt_parity_bit == 1'b1);

    always@(posedge i_sys_clk)
    begin
        if(~i_sys_rstn | w_parity_sample_end)
        begin
            r_cnt_parity_bit <= 'd0;
            r_parity_er <= 'd0;
        end
        else if(w_parity_sample_en)
        begin
            r_cnt_parity_bit <= r_cnt_parity_bit + 1'b1;
            r_parity_er <= r_uart_rx[2];
        end
    end

    always@(posedge i_sys_clk)
    begin
        if(~i_sys_rstn)
        begin
            r_parity_er1 <= 'd0;
        end
        else if(w_parity_sample_end)
        begin
            r_parity_er1 <= r_parity_er;
        end
    end
/******************************************************************************\
Uart rx stop sample
\******************************************************************************/
    assign w_stop_sample_en  = (r_current_state == S_STOP) && (w_baud_pos | w_baud_neg);
    assign w_stop_sample_end = (r_current_state == S_STOP) && (r_cnt_stop_bit == r_stop_bit);

    always@(posedge i_sys_clk)
    begin
        if(~i_sys_rstn | w_stop_sample_end)
        begin
            r_cnt_stop_bit <= 'd0;
        end
        else if(w_stop_sample_en)
        begin
            r_cnt_stop_bit <= r_cnt_stop_bit + 1'b1;
        end
    end

    assign o_rx_data  = {r_rx_data1,r_parity_er1};
    assign o_rx_valid = w_stop_sample_end;

endmodule