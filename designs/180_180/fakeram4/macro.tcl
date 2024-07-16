set block [ord::get_db_block]
set units [$block getDefUnits]
set vals [list 2 2 150 10]
lassign $vals rows cols offset pitch

for {set row 0} {$row < $rows} {incr row} {
    for {set col 0} {$col < $cols} {incr col} {
        set inst [$block findInst [format "dmem%d%d" $row $col]]
        puts "row=$row,col=$col"
        set x [expr round( ($offset + (($pitch + 450) * $col)) * $units )]
        set y [expr round( ($offset + (($pitch + 350) * $row)) * $units )]
        $inst setOrigin $x $y
        puts "x=$x"
        puts "y=$y"
        $inst setPlacementStatus FIRM
    }
}