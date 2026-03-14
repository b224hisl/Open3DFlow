utl::set_metrics_stage "finish__{}"
source $::env(SCRIPTS_DIR)/load.tcl
erase_non_stage_variables final
load_design 6_1_fill.odb 6_1_fill.sdc
set tsv_loc_file [file join $::env(RESULTS_DIR) tsv_resize.txt]

set_propagated_clock [all_clocks]

# Ensure all OR created (rsz/cts) instances are connected
global_connect

write_db $::env(RESULTS_DIR)/6_final.odb
write_lef $::env(RESULTS_DIR)/hehe.lef
write_verilog $::env(RESULTS_DIR)/hehe.v
write_def $::env(RESULTS_DIR)/hehe.def

# Delete routing obstructions for final DEF
source $::env(SCRIPTS_DIR)/deleteRoutingObstructions.tcl
deleteRoutingObstructions

write_def $::env(RESULTS_DIR)/6_final.def
write_verilog $::env(RESULTS_DIR)/6_final.v

# Run extraction and STA
if {[env_var_exists_and_non_empty RCX_RULES]} {

  # Set RC corner for RCX
  # Set in config.mk
  if {[env_var_exists_and_non_empty RCX_RC_CORNER]} {
    set rc_corner $::env(RCX_RC_CORNER)
  }

  # RCX section
  define_process_corner -ext_model_index 0 X
  extract_parasitics -ext_model_file $::env(RCX_RULES)

  # Write Spef
  write_spef $::env(RESULTS_DIR)/6_final.spef
  file delete $::env(DESIGN_NAME).totCap

  # Read Spef for OpenSTA
  read_spef $::env(RESULTS_DIR)/6_final.spef

  # Static IR drop analysis
  if {[env_var_exists_and_non_empty PWR_NETS_VOLTAGES]} {
    dict for {pwrNetName pwrNetVoltage}  {*}$::env(PWR_NETS_VOLTAGES) {
        set_pdnsim_net_voltage -net ${pwrNetName} -voltage ${pwrNetVoltage}
        puts "help!"
        # check_power_grid -net VDD
        # if {[info exits ::env(TSV_LOC)]} {
        #   puts "power tsv!"
        #   analyze_power_grid -net ${pwrNetName} -vsrc $tsv_loc_file -error_file $::env(REPORTS_DIR)/${pwrNetName}.rpt
        # } 
        # else {
        puts "power!"
        check_power_grid -net VDD
        analyze_power_grid -net ${pwrNetName} \
        -error_file $::env(REPORTS_DIR)/${pwrNetName}.rpt
        # }
        puts "end!"
    }
  } else {
    puts "IR drop analysis for power nets is skipped because PWR_NETS_VOLTAGES is undefined"
  }
  if {[env_var_exists_and_non_empty GND_NETS_VOLTAGES]} {
    dict for {gndNetName gndNetVoltage}  {*}$::env(GND_NETS_VOLTAGES) {
        set_pdnsim_net_voltage -net ${gndNetName} -voltage ${gndNetVoltage}
        analyze_power_grid -net ${gndNetName} \
            -error_file $::env(REPORTS_DIR)/${gndNetName}.rpt
    }
  } else {
    puts "IR drop analysis for ground nets is skipped because GND_NETS_VOLTAGES is undefined"
  }

} else {
  puts "OpenRCX is not enabled for this platform."
}

report_cell_usage

report_metrics 6 "finish"
# write_abstrat_lef $::env(RESULTS_DIR)/6_final.lef
# write_lib $::env(RESULTS_DIR)/6_final.lib

# Save a final image if openroad is compiled with the gui
# if {[expr [llength [info procs save_image]] > 0]} {
#     gui::show "source $::env(SCRIPTS_DIR)/save_images.tcl" false
# }
