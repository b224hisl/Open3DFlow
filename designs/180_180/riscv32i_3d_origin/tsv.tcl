set block [ord::get_db_block]
set units [$block getDefUnits]
set vals [list 1 4 20 60]
lassign $vals rows cols offset pitch

for {set row 0} {$row < $rows} {incr row} {
    for {set col 0} {$col < $cols} {incr col} {
        set inst [$block findInst [format "dmem%d" $col]]

        puts "col=$col"
        if {$col%2==0} { 
            puts "hehe"
            $inst setOrient R0
            puts "hehe"
            set x [expr round( ($offset + ($pitch * $col)) * $units )]
            set y [expr round( 20 * $units)]
        } else {
            $inst setOrient R180
            set x [expr round( ($offset + ($pitch * $col) + 30) * $units )]
            set y [expr round( (20 + 87.28) * $units)]
        }

        $inst setOrigin $x $y
        puts "x=$x"
        puts "y=$y"
        $inst setPlacementStatus FIRM
    }
}