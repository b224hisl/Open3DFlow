module mem_64_16_gf180(
	input clk,
	input ce,
	input we,
	// input wmask,
    input [5:0] addr,
	input [15:0] idat,
	output [15:0] odat
);

genvar i;
generate
    for(i = 0; i < 2; i=i+1) begin
        gf180mcu_fd_ip_sram__sram64x8m8wm1 sram_u(
            .CLK(clk),
            .CEN(ce),    //Chip Enable
            .GWEN(~we),   //Global Write Enable
            .WEN(8'b1),    //Write Enable
            .A(addr),
            .D(idat[i*8+7:i*8]),
            .Q(odat[i*8+7:i*8]),
        );
    end
endgenerate

endmodule
