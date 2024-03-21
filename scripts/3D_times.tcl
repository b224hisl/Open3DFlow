# can be expanded for other 3D architecture
utl::set_metrics_stage "3d_time__{}"

#source $::env(SCRIPTS_DIR)/load.tcl
#load_design 3_place.odb 2_floorplan.sdc "adding delay caused by tsv"

set sdcname "$::env(RESULTS_DIR)/3_tsv_place.sdc"
set sdc [open $sdcname "w"]

set refname "$::env(SDC_FILE)"
set ref [open $refname "r"]

while {[gets $ref line] >= 0} {  
    if {[string match "set clk_io_pct 0" $line]} {  
        puts $sdc "set clk_io_pct $::env(TSV_DELAY)"  
    } else {  
        puts $sdc $line  
    }  
}

exec mv $::env(RESULTS_DIR)/3_tsv_place.sdc $::env(RESULTS_DIR)/3_place.sdc

close $sdc
close $ref
puts "Finsh adding delay caused by TSV"




