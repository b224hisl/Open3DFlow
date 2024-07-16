`timescale  1ns/1ps
module Uart_tx
(
    input                             i_sys_clk         ,
    input                             i_sys_rstn        ,

    input            [31:0]           i_fre_cnt         ,
    input            [3:0]            i_tx_data_bit     ,
    input            [2:0]            i_parity_mode     ,
    input            [2:0]            i_stop_bit        ,
    input            [7:0]            i_tx_data         ,
    input                             i_tx_valid        ,
    output    reg                     o_tx_req          ,
    output    reg                     o_uart_tx
);
    localparam        S_IDLE             = 5'h01;
    localparam        S_START            = 5'h02;
    localparam        S_DATA             = 5'h04;
    localparam        S_PARITY           = 5'h08;
    localparam        S_STOP             = 5'h10;

    reg                [31:0]           r_fre_cnt        ;
    reg                [3:0]            r_tx_data_bit    ;
    reg                [2:0]            r_parity_mode    ;
    reg                [2:0]            r_stop_bit       ;
    reg                [31:0]           r_fre_sum        ;
    reg                                 r_baud_fre       ;
    reg                [4:0]            r_cur_state      ;
    reg                [4:0]            r_next_state     ;
    reg                [7:0]            r_uart_tx_data   ;
    reg                [7:0]            r_tx_data        ;
    reg                [3:0]            r_cnt_tx_bit     ;
    reg                [2:0]            r_cnt_stop_bit   ;
    reg                                 r_parity         ;
    reg                                 r_tx_data_en     ;
    wire                                w_baud_pos       ;
    wire                                w_baud_neg       ;
    wire                                w_tx_start_en    ;
    wire                                w_tx_data_en     ;
    wire                                w_tx_data_end    ;
    wire                                w_parity_end     ;
    wire                                w_tx_stop_en     ;
    wire                                w_tx_stop_end    ;


    function oneadd;
        input    [7:0]    i_data;
        begin
            oneadd = i_data[7] + i_data[6] + i_data[5] + i_data[4] + i_data[3] + i_data[2] + i_data[1] + i_data[0];
        end
    endfunction
/******************************************************************************\
Synchronous signal
\******************************************************************************/
    always@(posedge i_sys_clk)
    begin
        if(~i_sys_rstn)
        begin
            r_fre_cnt        <= 'd0;
            r_tx_data_bit    <= 'd0;
            r_parity_mode    <= 'd0;
            r_stop_bit       <= 'd0;
        end
        else
        begin
            r_fre_cnt        <= i_fre_cnt     ;
            r_tx_data_bit    <= i_tx_data_bit ;
            r_parity_mode    <= i_parity_mode ;
            r_stop_bit       <= i_stop_bit    ;
        end
    end
/******************************************************************************\
Generate sample baud rate signal
\******************************************************************************/
    always@(posedge i_sys_clk)
    begin
        if(~i_sys_rstn)
        begin
            r_fre_sum <= 32'hffffffff;
        end
        else
        begin
            r_fre_sum <= r_fre_sum + r_fre_cnt;
        end
    end
    always@(posedge i_sys_clk)
    begin
        r_baud_fre <= r_fre_sum[31];
    end

    assign w_baud_pos = ~r_baud_fre    & r_fre_sum[31];
    assign w_baud_neg = ~r_fre_sum[31] & r_baud_fre   ;

/******************************************************************************\
State machine
\******************************************************************************/
    always@(posedge i_sys_clk)
    begin
        if(~i_sys_rstn)
        begin
            r_cur_state <= S_IDLE;
        end
        else
        begin
            r_cur_state <= r_next_state;
        end
    end

    always@(*)
    begin
        r_next_state = 'd1;
        case(r_cur_state)
            S_IDLE:
                    begin
                        if(i_tx_valid & w_baud_neg)
                        begin
                            r_next_state = S_START;
                        end
                        else
                        begin
                            r_next_state = S_IDLE;
                        end
                    end
            S_START:
                    begin
                        if(w_tx_start_en)
                        begin
                            r_next_state = S_DATA;
                        end
                        else
                        begin
                            r_next_state = S_START;
                        end
                    end
            S_DATA:
                    begin
                        if(w_tx_data_end)
                        begin
                            if(r_parity_mode[2])
                            begin
                                r_next_state = S_STOP;
                            end
                            else
                            begin
                                r_next_state = S_PARITY;
                            end
                        end
                        else
                        begin
                            r_next_state = S_DATA;
                        end
                    end
            S_PARITY:
                    begin
                        if(w_parity_end)
                        begin
                            r_next_state = S_STOP;
                        end
                        else
                        begin
                            r_next_state = S_PARITY;
                        end
                    end
            S_STOP:
                    begin
                        if(w_tx_stop_end)
                        begin
                            r_next_state = S_IDLE;
                        end
                        else
                        begin
                            r_next_state = S_STOP;
                        end
                    end
            default: r_next_state = S_IDLE;
        endcase
    end

/******************************************************************************\
Uart tx data
\******************************************************************************/
    assign w_tx_start_en    = (r_cur_state == S_START) & w_baud_neg;
    assign w_tx_data_en     = (r_cur_state == S_DATA) & w_baud_neg;
    assign w_tx_data_end    = (r_cur_state == S_DATA) & (r_cnt_tx_bit == r_tx_data_bit);
    assign w_parity_end     = (r_cur_state == S_PARITY) & w_baud_neg;
    assign w_tx_stop_en     = (r_cur_state == S_STOP) & (w_baud_neg | w_baud_pos);
    assign w_tx_stop_end    = (r_cur_state == S_STOP) & (r_cnt_stop_bit == r_stop_bit);

    always@(posedge i_sys_clk)
    begin
        r_tx_data_en <= w_tx_data_en;
    end

    always@(posedge i_sys_clk)
    begin
        if(~i_sys_rstn)
        begin
            r_uart_tx_data <= 8'hff;
        end
        else if(w_tx_start_en)
        begin
            r_uart_tx_data <= r_tx_data;
        end
        else if(r_tx_data_en)
        begin
            r_uart_tx_data <= {1'b1,r_uart_tx_data[7:1]};
        end
    end

    always@(posedge i_sys_clk)
    begin
        if(~i_sys_rstn | w_tx_data_end)
        begin
            r_cnt_tx_bit <= 'd0;
        end
        else if(w_tx_data_en)
        begin
            r_cnt_tx_bit <= r_cnt_tx_bit + 1'b1;
        end
    end

    always@(posedge i_sys_clk)
    begin
        if(~i_sys_rstn | w_tx_stop_end)
        begin
            r_cnt_stop_bit <= 'd0;
        end
        else if(w_tx_stop_en)
        begin
            r_cnt_stop_bit <= r_cnt_stop_bit + 1'b1;
        end
    end

    always@(*)
    begin
        case(r_cur_state)
            S_START:
                if(w_baud_pos & i_tx_valid)
                    o_tx_req = 1'b1;
                else
                    o_tx_req = 1'b0;
            default:
                    o_tx_req = 1'b0;
        endcase
    end
    assign w_deal_en = i_tx_valid & o_tx_req;

/******************************************************************************\
Uart tx parity
\******************************************************************************/
    always@(posedge i_sys_clk)
    begin
        if(w_deal_en)
        begin
            r_tx_data <= i_tx_data;
        end
    end

    always@(*)
    begin
        case(r_parity_mode)
            3'd0        : r_parity = oneadd(r_tx_data) ? 1'b0 : 1'b1;                    //Odd parity
            3'd1        : r_parity = oneadd(r_tx_data) ? 1'b1 : 1'b0;                    //Even parity
            3'd2        : r_parity = 'd1;                                                //Mark parity
            3'd3        : r_parity = 'd0;                                                //Space parity
            default     : r_parity = 'd0;                                                //No parity
        endcase
    end
/******************************************************************************\
Uart tx serial port
\******************************************************************************/
    always@(*)
    begin
        case(r_cur_state)
            S_START       : o_uart_tx = 'd0;
            S_DATA        : o_uart_tx = r_uart_tx_data[0];
            S_PARITY      : o_uart_tx = r_parity;
            S_STOP        : o_uart_tx = 'd1;
            default       : o_uart_tx = 'd1;
        endcase
    end

endmodule