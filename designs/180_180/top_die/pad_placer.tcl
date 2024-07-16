puts "adding pads according to the mother die"
source $::env(SCRIPTS_DIR)/util.tcl
# #clk
# place_pin -pin_name clk -pin_size {1 1} -layer Bonding_layer -location {0 770}

# cluster1
set icache_valid_i [match_pins icache_valid_i]
set icache_addr_i [match_pins icache_addr_i]
set cluster1 [concat $icache_valid_i $icache_addr_i]
set cluster1_locname "$::env(MOTHER_DIR)/cluster1.txt"
set cluster1_loc [open $cluster1_locname "r"]

foreach c1 $cluster1 {
    gets $cluster1_loc line
    set x_y $line
    set x [lindex $x_y 0]
    set y [lindex $x_y 1]
    set xy_list [list $x $y]
    place_pin -layer Bonding_layer -pin_size {1 1} -pin_name $c1 -location $xy_list
}
close $cluster1_loc

# cluster2
set icache_valid_o [match_pins icache_valid_o]
set icache_dat_o [match_pins icache_dat_o]
set cluster2 [concat $icache_valid_o $icache_dat_o]
set cluster2_locname "$::env(MOTHER_DIR)/cluster2.txt"
set cluster2_loc [open $cluster2_locname "r"]
foreach c2 $cluster2 {
    gets $cluster2_loc line
    set x_y $line
    set x [lindex $x_y 0]
    set y [lindex $x_y 1]
    set xy_list [list $x $y]
    place_pin -layer Bonding_layer -pin_size {1 1} -pin_name $c2 -location $xy_list
}
close $cluster2_loc

# prequisits
set dcache_dat_i [match_pins dcache_dat_i]

# cluster3
set dcache_valid_i [match_pins dcache_valid_i]
set dcache_we_i [match_pins dcache_we_i]
set dcache_addr_i [match_pins dcache_addr_i]
set dcache_dat_i_low [lrange $dcache_dat_i 0 14]
set cluster3 [concat $dcache_valid_i $dcache_we_i $dcache_addr_i $dcache_dat_i_low]
set cluster3_locname "$::env(MOTHER_DIR)/cluster3.txt"
set cluster3_loc [open $cluster3_locname "r"]
foreach c3 $cluster3 {
    gets $cluster3_loc line
    set x_y $line
    set x [lindex $x_y 0]
    set y [lindex $x_y 1]
    set xy_list [list $x $y]
    place_pin -layer Bonding_layer -pin_size {1 1} -pin_name $c3 -location $xy_list
}
close $cluster3_loc

# cluster4
set dcache_valid_o [match_pins dcache_valid_o]
set dcache_dat_o [match_pins dcache_dat_o]
set dcache_dat_i_high [lrange $dcache_dat_i 15 31]
set cluster4 [concat $dcache_valid_o $dcache_dat_o $dcache_dat_i_high]
set cluster4_locname "$::env(MOTHER_DIR)/cluster4.txt"
set cluster4_loc [open $cluster4_locname "r"]
foreach c4 $cluster4 {
    gets $cluster4_loc line
    set x_y $line
    set x [lindex $x_y 0]
    set y [lindex $x_y 1]
    set xy_list [list $x $y]
    place_pin -layer Bonding_layer -pin_size {1 1} -pin_name $c4 -location $xy_list
}
close $cluster4_loc

place_pins -ver_layers Metal4 -hor_layers Bonding_layer
#place_pin -pin_name dcache_dat_i[4] -pin_size {1 1} -location {515 1599} -layer Bonding_layer
make_tracks Metal4 -x_pitch 0.1 -y_pitch 0.1