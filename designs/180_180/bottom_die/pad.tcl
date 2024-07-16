source $::env(SCRIPTS_DIR)/util.tcl
source /Flow/scripts/util.tcl

set icache_valid_o [match_pins icache_valid_o]
set icache_addr_o [match_pins icache_addr_o]
set cluster1 [concat $icache_valid_o $icache_addr_o]

set icache_valid_i [match_pins icache_valid_i]
set icache_dat_i [match_pins icache_dat_i]
set cluster2 [concat $icache_valid_i $icache_dat_i]

set dcache_dat_o [match_pins dcache_dat_o]

set dcache_valid_o [match_pins dcache_valid_o]
set dcache_we_o [match_pins dcache_we_o]
set dcache_addr_o [match_pins dcache_addr_o]
set dcache_dat_o_low [lrange $dcache_dat_o 0 14]
set cluster3 [concat $dcache_valid_o $dcache_we_o $dcache_addr_o $dcache_dat_o_low]

set dcache_valid_i [match_pins dcache_valid_i]
set dcache_dat_i [match_pins dcache_dat_i]
set dcache_dat_o_high [lrange $dcache_dat_o 15 31]
set cluster4 [concat $dcache_valid_i $dcache_dat_i $dcache_dat_o_high]
 
define_pin_shape_pattern -layer Bonding_layer -region {100 1600 3120 2100} -size {1 1} -x_step 15 -y_step 5

set_io_pin_constraint -region "up:{100 1850 1610 2100}" -pin_names $cluster1 
set_io_pin_constraint -region "up:{1610 1850 3120 2100}" -pin_names $cluster2 
set_io_pin_constraint -region "up:{100 1600 1610 1850}" -pin_names $cluster3 
set_io_pin_constraint -region "up:{1610 1600 3120 1850}" -pin_names $cluster4

place_pins -ver_layers Metal4 -hor_layers Bonding_layer
# special pin
place_pin -pin_name dcache_dat_o[4] -pin_size {1 1} -location {515 1599} -layer Bonding_layer
make_tracks Metal4 -x_pitch 0.1 -y_pitch 0.1