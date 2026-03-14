puts "manuual placement of parts"

place_cell -cell ddr -inst_name DDR1 -orient R180 -origin "13000 14000" -status "FIRM"
place_cell -cell ddr -inst_name DDR2 -orient R180 -origin "31545 14000" -status "FIRM"
place_cell -cell ddr -inst_name DDR3 -orient R180 -origin "31545 27300" -status "FIRM"
place_cell -cell ddr -inst_name DDR4 -orient R180 -origin "13000 27300" -status "FIRM"

place_cell -cell soc -inst_name u_soc -orient R0 -origin "15300 11434" -status "FIRM"
