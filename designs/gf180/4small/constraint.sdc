current_design mem_64_32_gf180
set clk_name  clk
set clk_port_name clk
set clk_period 12.5
set clk_io_pct 0

set clk_port [get_ports $clk_port_name]

create_clock -name $clk_name -period $clk_period $clk_port
