puts "adding pads according to the mother die"
source $::env(SCRIPTS_DIR)/util.tcl
#clk
place_pin -pin_name clk -pin_size {0.44 1.28} -layer Metal4 -location {0 770}

# writedata
set writedata [match_pins writedata*]
set writedata_locname "$::env(MOTHER_DIR)/writedata_loca.txt"
set writedata_loc [open $writedata_locname "r"]

foreach wd $writedata {
    gets $writedata_loc line
    set x_y $line
    set x [lindex $x_y 0]
    set y [lindex $x_y 1]
    set xy_list [list $x $y]
    place_pin -layer Metal4 -pin_size {0.44 1.28} -pin_name $wd -location $xy_list
}
close $writedata_loc

# dataadr
set dataadr [match_pins dataadr*]
set dataadr_locname "$::env(MOTHER_DIR)/dataadr_loca.txt"
set dataadr_loc [open $dataadr_locname "r"]
foreach da $dataadr {
    gets $dataadr_loc line
    set x_y $line
    set x [lindex $x_y 0]
    set y [lindex $x_y 1]
    set xy_list [list $x $y]
    place_pin -layer Metal4 -pin_size {0.44 1.28} -pin_name $da -location $xy_list
}
close $dataadr_loc

# inter_dmem
set inter_dmem [match_pins inter_dmem*]
set inter_dmem_locname "$::env(MOTHER_DIR)/inter_dmem_loca.txt"
set inter_dmem_loc [open $inter_dmem_locname "r"]
foreach id $inter_dmem {
    gets $inter_dmem_loc line
    set x_y $line
    set x [lindex $x_y 0]
    set y [lindex $x_y 1]
    set xy_list [list $x $y]
    place_pin -layer Metal4 -pin_size {0.44 1.28} -pin_name $id -location $xy_list
}
close $inter_dmem_loc


# ce_mem/we_mem
set e_mem [match_pins e_mem*]
set e_mem_locname "$::env(MOTHER_DIR)/e_mem_loca.txt"
set e_mem_loc [open $e_mem_locname "r"]
foreach em $e_mem {
    gets $e_mem_loc line
    set x_y $line
    set x [lindex $x_y 0]
    set y [lindex $x_y 1]
    set xy_list [list $x $y]
    place_pin -layer Metal4 -pin_size {0.44 1.28} -pin_name $em -location $xy_list
}
close $e_mem_loc
