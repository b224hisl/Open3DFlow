set block [ord::get_db_block]
set units [$block getDefUnits]
set tsv_loc [open $::env(TSV_LOC) r]

for {set i 0} {$i < $::env(TSV_NUM)} {incr i} {
    gets $tsv_loc line
    set value [split $line ","]
    set x [lindex $value 0]
    set y [lindex $value 1]
    puts "tsv$i's initial location : $x $y, unit in um!"
    place_cell -cell tsv -inst_name tsv_$i -origin "$x $y" -orient R0 -status "PLACED"    
}