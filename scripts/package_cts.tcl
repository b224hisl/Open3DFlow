utl::set_metrics_stage "cts__{}"
source $::env(SCRIPTS_DIR)/load.tcl
erase_non_stage_variables cts

load_design 3_place.odb 3_place.sdc

puts "for packageusage to finish cts step"
write_sdc -no_timestamp $::env(RESULTS_DIR)/4_cts.sdc
write_db $::env(RESULTS_DIR)/4_1_cts.odb