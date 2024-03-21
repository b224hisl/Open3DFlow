current_design dmem

set clk_name  clk
set clk_port_name clk
set clk_period 12.5
set clk_io_pct 0
set f2f_delay [expr $clk_period * $clk_io_pct]

set clk_port [get_ports $clk_port_name]

create_clock -name $clk_name -period $clk_period $clk_port

## input 
set_input_delay [expr (207.500 + $f2f_delay)] -clock [get_clocks {clk}] -add_delay [get_ports {writedata[0]}]
set_input_delay [expr (207.500 + $f2f_delay)] -clock [get_clocks {clk}] -add_delay [get_ports {writedata[1]}]
set_input_delay [expr (207.500 + $f2f_delay)] -clock [get_clocks {clk}] -add_delay [get_ports {writedata[2]}]
set_input_delay [expr (207.500 + $f2f_delay)] -clock [get_clocks {clk}] -add_delay [get_ports {writedata[3]}]
set_input_delay [expr (207.500 + $f2f_delay)] -clock [get_clocks {clk}] -add_delay [get_ports {writedata[4]}]
set_input_delay [expr (207.500 + $f2f_delay)] -clock [get_clocks {clk}] -add_delay [get_ports {writedata[5]}]
set_input_delay [expr (207.500 + $f2f_delay)] -clock [get_clocks {clk}] -add_delay [get_ports {writedata[6]}]
set_input_delay [expr (207.500 + $f2f_delay)] -clock [get_clocks {clk}] -add_delay [get_ports {writedata[7]}]

set_input_delay [expr (207.500 + $f2f_delay)] -clock [get_clocks {clk}] -add_delay [get_ports {ce_mem[0]}]
set_input_delay [expr (207.500 + $f2f_delay)] -clock [get_clocks {clk}] -add_delay [get_ports {ce_mem[1]}]
set_input_delay [expr (207.500 + $f2f_delay)] -clock [get_clocks {clk}] -add_delay [get_ports {ce_mem[2]}]
set_input_delay [expr (207.500 + $f2f_delay)] -clock [get_clocks {clk}] -add_delay [get_ports {ce_mem[3]}]

set_input_delay [expr (207.500 + $f2f_delay)] -clock [get_clocks {clk}] -add_delay [get_ports {we_mem[0]}]
set_input_delay [expr (207.500 + $f2f_delay)] -clock [get_clocks {clk}] -add_delay [get_ports {we_mem[1]}]
set_input_delay [expr (207.500 + $f2f_delay)] -clock [get_clocks {clk}] -add_delay [get_ports {we_mem[2]}]
set_input_delay [expr (207.500 + $f2f_delay)] -clock [get_clocks {clk}] -add_delay [get_ports {we_mem[3]}]

set_input_delay [expr (207.500 + $f2f_delay)] -clock [get_clocks {clk}] -add_delay [get_ports {dataadr[0]}]
set_input_delay [expr (207.500 + $f2f_delay)] -clock [get_clocks {clk}] -add_delay [get_ports {dataadr[1]}]
set_input_delay [expr (207.500 + $f2f_delay)] -clock [get_clocks {clk}] -add_delay [get_ports {dataadr[2]}]
set_input_delay [expr (207.500 + $f2f_delay)] -clock [get_clocks {clk}] -add_delay [get_ports {dataadr[3]}]
set_input_delay [expr (207.500 + $f2f_delay)] -clock [get_clocks {clk}] -add_delay [get_ports {dataadr[4]}]
set_input_delay [expr (207.500 + $f2f_delay)] -clock [get_clocks {clk}] -add_delay [get_ports {dataadr[5]}]
set_input_delay [expr (207.500 + $f2f_delay)] -clock [get_clocks {clk}] -add_delay [get_ports {dataadr[6]}]
set_input_delay [expr (207.500 + $f2f_delay)] -clock [get_clocks {clk}] -add_delay [get_ports {dataadr[7]}]


# output
set_output_delay [expr (207.500 + $f2f_delay)] -clock [get_clocks {clk}] -add_delay [get_ports {inter_dmem0[0]}]
set_output_delay [expr (207.500 + $f2f_delay)] -clock [get_clocks {clk}] -add_delay [get_ports {inter_dmem0[1]}]
set_output_delay [expr (207.500 + $f2f_delay)] -clock [get_clocks {clk}] -add_delay [get_ports {inter_dmem0[2]}]
set_output_delay [expr (207.500 + $f2f_delay)] -clock [get_clocks {clk}] -add_delay [get_ports {inter_dmem0[3]}]
set_output_delay [expr (207.500 + $f2f_delay)] -clock [get_clocks {clk}] -add_delay [get_ports {inter_dmem0[4]}]
set_output_delay [expr (207.500 + $f2f_delay)] -clock [get_clocks {clk}] -add_delay [get_ports {inter_dmem0[5]}]
set_output_delay [expr (207.500 + $f2f_delay)] -clock [get_clocks {clk}] -add_delay [get_ports {inter_dmem0[6]}]
set_output_delay [expr (207.500 + $f2f_delay)] -clock [get_clocks {clk}] -add_delay [get_ports {inter_dmem0[7]}]
set_output_delay [expr (207.500 + $f2f_delay)] -clock [get_clocks {clk}] -add_delay [get_ports {inter_dmem1[0]}]
set_output_delay [expr (207.500 + $f2f_delay)] -clock [get_clocks {clk}] -add_delay [get_ports {inter_dmem1[1]}]
set_output_delay [expr (207.500 + $f2f_delay)] -clock [get_clocks {clk}] -add_delay [get_ports {inter_dmem1[2]}]
set_output_delay [expr (207.500 + $f2f_delay)] -clock [get_clocks {clk}] -add_delay [get_ports {inter_dmem1[3]}]
set_output_delay [expr (207.500 + $f2f_delay)] -clock [get_clocks {clk}] -add_delay [get_ports {inter_dmem1[4]}]
set_output_delay [expr (207.500 + $f2f_delay)] -clock [get_clocks {clk}] -add_delay [get_ports {inter_dmem1[5]}]
set_output_delay [expr (207.500 + $f2f_delay)] -clock [get_clocks {clk}] -add_delay [get_ports {inter_dmem1[6]}]
set_output_delay [expr (207.500 + $f2f_delay)] -clock [get_clocks {clk}] -add_delay [get_ports {inter_dmem1[7]}]
set_output_delay [expr (207.500 + $f2f_delay)] -clock [get_clocks {clk}] -add_delay [get_ports {inter_dmem2[0]}]
set_output_delay [expr (207.500 + $f2f_delay)] -clock [get_clocks {clk}] -add_delay [get_ports {inter_dmem2[1]}]
set_output_delay [expr (207.500 + $f2f_delay)] -clock [get_clocks {clk}] -add_delay [get_ports {inter_dmem2[2]}]
set_output_delay [expr (207.500 + $f2f_delay)] -clock [get_clocks {clk}] -add_delay [get_ports {inter_dmem2[3]}]
set_output_delay [expr (207.500 + $f2f_delay)] -clock [get_clocks {clk}] -add_delay [get_ports {inter_dmem2[4]}]
set_output_delay [expr (207.500 + $f2f_delay)] -clock [get_clocks {clk}] -add_delay [get_ports {inter_dmem2[5]}]
set_output_delay [expr (207.500 + $f2f_delay)] -clock [get_clocks {clk}] -add_delay [get_ports {inter_dmem2[6]}]
set_output_delay [expr (207.500 + $f2f_delay)] -clock [get_clocks {clk}] -add_delay [get_ports {inter_dmem2[7]}]
set_output_delay [expr (207.500 + $f2f_delay)] -clock [get_clocks {clk}] -add_delay [get_ports {inter_dmem3[0]}]
set_output_delay [expr (207.500 + $f2f_delay)] -clock [get_clocks {clk}] -add_delay [get_ports {inter_dmem3[1]}]
set_output_delay [expr (207.500 + $f2f_delay)] -clock [get_clocks {clk}] -add_delay [get_ports {inter_dmem3[2]}]
set_output_delay [expr (207.500 + $f2f_delay)] -clock [get_clocks {clk}] -add_delay [get_ports {inter_dmem3[3]}]
set_output_delay [expr (207.500 + $f2f_delay)] -clock [get_clocks {clk}] -add_delay [get_ports {inter_dmem3[4]}]
set_output_delay [expr (207.500 + $f2f_delay)] -clock [get_clocks {clk}] -add_delay [get_ports {inter_dmem3[5]}]
set_output_delay [expr (207.500 + $f2f_delay)] -clock [get_clocks {clk}] -add_delay [get_ports {inter_dmem3[6]}]
set_output_delay [expr (207.500 + $f2f_delay)] -clock [get_clocks {clk}] -add_delay [get_ports {inter_dmem3[7]}]