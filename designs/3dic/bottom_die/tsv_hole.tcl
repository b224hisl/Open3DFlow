puts "begin TSV insertion, creating tsv holes"
set block [ord::get_db_block]
set units [$block getDefUnits]
set width [expr int($::env(TSV_SIZE))]
set tsv_loc_file [file join $::env(RESULTS_DIR) tsv_resize.txt]
catch {file delete $tsv_loc_file}

for {set i 0} {$i < $::env(TSV_NUM)} {incr i} {
    set tsv [$block findInst "tsv_$i"]
    set loc [$tsv getLocation]
    set x [lindex $loc 0]
    set y [lindex $loc 1]
    exec python3 $::env(DESIGN_DIR)/tsv_resize.py $x $y
    # int convertion
    set xr_l [expr $x/$units]
    set yr_l [expr $y/$units]
    set xr_r [expr $xr_l + $width]
    set yr_h [expr $yr_l + $width]
    puts "TSV$i's hole box: $xr_l $yr_l $xr_r $yr_h"
    for {set m 1} {$m < $::env(TSV_PEN)} {incr m} {
        set layer [[ord::get_db_tech] findLayer Metal$m]
        if {$layer == "NULL"} {
            puts "Warning: Layer Metal$m not found!"
        } else {
            odb::dbObstruction_create $block $layer $xr_l $yr_l $xr_r $yr_h
            odb::dbObstruction_create $block $layer $xr_l $yr_l $xr_r $yr_h
    }
}
}

puts "Finish the resized tsv location file"
puts "TSV insertion has done"