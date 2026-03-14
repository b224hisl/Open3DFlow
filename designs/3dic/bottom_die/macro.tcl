set block [ord::get_db_block]
set units [$block getDefUnits]
set vals [list 1 2 80 80 620 0]
lassign $vals rows cols offsetx offsety pitchx pitchy

set inst1 [$block findInst "l1d_u"]
puts "setting the location of dcache"
set x1 [expr round( ($offsetx * $units ) )]
set y [expr round( ($offsety * $units ) )]
$inst1 setOrigin $x1 $y
$inst1 setPlacementStatus FIRM

set inst2 [$block findInst "l1i_u"]
puts "setting the location of icache"
set x2 [expr round( (($offsetx + $pitchx + 1220) * $units ) )]
set y2 [expr round( (($offsety + $pitchy) * $units ) )]
$inst2 setOrigin $x2 $y2
$inst2 setPlacementStatus FIRM