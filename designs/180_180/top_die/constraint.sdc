current_design top_die
set clk_name  clk
set clk_port_name clk
#40MHz
set clk_period 40

set clk_io_pct 0

set clk_port [get_ports $clk_port_name]

create_clock -name $clk_name -period $clk_period $clk_port
# set_false_path -from [get_pins l1i_u/clk] \
#  -to [get_pins l1d_u/addr[15]]

# set_multicycle_path -hold -rise -from [get_pins tag_ram/*] \
#  -to [get_pins dat_ram/*] -end 10

# set_false_path -from [get_pins tag_ram/*] \
#  -to [get_pins dat_ram/*]

# set_multicycle_path -setup -rise -from [get_pins tag_ram/clk] \
# -through [list \
#  [get_pins _168_/A2]    \
#  [get_pins _169_/A4]    \
#  [get_pins _170_/A4]    \
#   [get_pins _321_/B1]    \
# ] \
#  -to [get_pins dat_ram/we] -end 10

#  set_multicycle_path -setup -rise -from [get_pins tag_ram/clk] \
#  -to [get_pins dat_ram/idat[*]] -end 2

#   set_multicycle_path -setup -rise -from [get_pins tag_ram/clk] \
#  -to [get_pins dat_ram/idat[10]] -end 2

#   set_multicycle_path -setup -rise -from [get_pins tag_ram/clk] \
#  -to [get_pins dat_ram/idat[11]] -end 2

#    set_multicycle_path -setup -rise -from [get_pins tag_ram/clk] \
#  -to [get_pins dat_ram/idat[12]] -end 2