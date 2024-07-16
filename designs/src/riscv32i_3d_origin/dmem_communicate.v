module dmem_communicate (clk, r_w, we_mem, ce_mem, mem_out, mem_addr, inter_dmem0, inter_dmem1, inter_dmem2, inter_dmem3);
    input 	 clk;
    input r_w;
    
    //output mem_data;
    output [3:0] we_mem;
    output [3:0] ce_mem;
    output [31:0] mem_out;

    input [31:0] mem_addr;
    input [7:0] inter_dmem0;
    input [7:0] inter_dmem1; 
    input [7:0] inter_dmem2; 
    input [7:0] inter_dmem3;

    wire [1:0] sel_mem;

    assign ce_mem = (mem_addr[31] == 1) ? 4'b1000 :
		       (mem_addr[23] == 1) ? 4'b0100 :
		       (mem_addr[15] == 1) ? 4'b0010 :
		       4'b0001;

    assign sel_mem = (mem_addr[31] == 1) ? 2'b11 :
        (mem_addr[23] == 1) ? 2'b10 :
        (mem_addr[15] == 1) ? 2'b01 :
        2'b00;
    
    always @* begin
      case (sel_mem)
	2'b00: mem_out = {24'b0,inter_dmem3};
	2'b01: mem_out = {24'b0,inter_dmem2};
	2'b10: mem_out = {24'b0,inter_dmem1};
	2'b11: mem_out = {24'b0,inter_dmem0};
      endcase // case (sel_mem)
   end

    always @* begin
        if (!r_w) begin
        we_mem = 4'b0000;
        end else if (mem_addr[31]) begin
        we_mem = 4'b1000;
        end else if (mem_addr[23]) begin
        we_mem = 4'b0100;
        end else if (mem_addr[15]) begin
        we_mem = 4'b0010;
        end else begin
        we_mem = 4'b0001;
        end
    end // always @ *



endmodule