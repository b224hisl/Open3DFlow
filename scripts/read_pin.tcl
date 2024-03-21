puts "adding pins according to the pin location file"
# some helper function
source /OpenRoad-flow-scripts/flow/designs/asap7/mock-array/util.tcl 

# writedata
set writedata [match_pins writedata*]
set writedata_locname "writedata_loca.txt"
set writedata_loc [open $writedata_locname "r"]

foreach wd $writedata {
    gets $writedata_loc line
    set x_y $line
    set x [lindex $x_y 0]
    set y [lindex $x_y 1]
    set xy_list [list $x $y]
    place_pin -layer Metal5 -pin_size {2.56 1.6} -pin_name $wd -location $xy_list
}
close $writedata_loc

# dataadr
set dataadr [match_pins dataadr*]
set dataadr_locname "dataadr_loca.txt"
set dataadr_loc [open $dataadr_locname "r"]
foreach da $dataadr {
    gets $dataadr_loc line
    set x_y $line
    set x [lindex $x_y 0]
    set y [lindex $x_y 1]
    set xy_list [list $x $y]
    place_pin -layer Metal5 -pin_size {2.56 1.6} -pin_name $da -location $xy_list
}
close $dataadr_loc

# inter_dmem
set inter_dmem [match_pins inter_dmem*]
set inter_dmem_locname "inter_dmem_loca.txt"
set inter_dmem_loc [open $inter_dmem_locname "r"]
foreach id $inter_dmem {
    gets $inter_dmem_loc line
    set x_y $line
    set x [lindex $x_y 0]
    set y [lindex $x_y 1]
    set xy_list [list $x $y]
    place_pin -layer Metal5 -pin_size {2.56 1.6} -pin_name $id -location $xy_list
}
close $inter_dmem_loc


# ce_mem/we_mem
set e_mem [match_pins e_mem*]
set e_mem_locname "e_mem_loca.txt"
set e_mem_loc [open $e_mem_locname "r"]
foreach em $e_mem {
    gets $e_mem_loc line
    set x_y $line
    set x [lindex $x_y 0]
    set y [lindex $x_y 1]
    set xy_list [list $x $y]
    place_pin -layer Metal5 -pin_size {2.56 1.6} -pin_name $em -location $xy_list
}
close $e_mem_loc