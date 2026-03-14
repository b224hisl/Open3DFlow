puts "manuual placement of parts"

place_cell -cell ddr -inst_name DDR1 -orient R180 -origin "18027.5 21050" -status "FIRM"
place_cell -cell ddr -inst_name DDR2 -orient R180 -origin "36972.5 21050" -status "FIRM"
place_cell -cell ddr -inst_name DDR3 -orient R180 -origin "36972.5 34550" -status "FIRM"
place_cell -cell ddr -inst_name DDR4 -orient R180 -origin "18027.5 34550" -status "FIRM"

place_cell -cell soc -inst_name u_soc -orient R0 -origin "20527.5 18764" -status "FIRM"
