source $::env(SCRIPTS_DIR)/util.tcl

set writedata [match_pins writedata*]
set writedata_list [concat {*}$writedata]

set dataadr [match_pins dataadr*]
set dataadr_list [concat {*}$dataadr]

set mem [match_pins _mem*]
set mem_list [concat {*}$mem]

set inter_dmem [match_pins inter_dmem*]
set inter_dmem_list [concat {*}$inter_dmem]


define_pin_shape_pattern -layer Metal4 -region {20 20 1180 980} -size {0.44 1.28} -x_step 10 -y_step 10

set_io_pin_constraint -region "up:{20 20 1180 40}" -pin_names $writedata_list
set_io_pin_constraint -region "up:{20 20 40 980}" -pin_names $mem_list
set_io_pin_constraint -region "up:{20 960 1180 980}" -pin_names $dataadr_list
set_io_pin_constraint -region "up:{1100 20 1180 980}" -pin_names $inter_dmem_list

place_pins -ver_layers Metal4 -hor_layers met5
#make_tracks Metal4 -x_pitch 0.1 -y_pitch 0.1