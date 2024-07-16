set block [ord::get_db_block]
set units [$block getDefUnits]
set vals [list 2 2 20 20 100 100]
lassign $vals rows cols offsetx offsety pitchx pitchy

for {set row 0} {$row < $rows} {incr row} {
    for {set col 0} {$col < $cols} {incr col} {
        set inst [$block findInst [format "genblk_%d_%d_sram_u" $row $col]]
        puts "row=$row,col=$col"
        set x [expr round( ($offsetx + (($pitchx + 431) * $col)) * $units )]
        set y [expr round( ($offsety + (($pitchy + 232) * $row)) * $units )]
        $inst setOrigin $x $y
        puts "x=$x"
        puts "y=$y"
        $inst setPlacementStatus FIRM
    }
}