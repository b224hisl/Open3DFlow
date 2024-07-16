set block [ord::get_db_block]
set units [$block getDefUnits]
set vals [list 2 1 100 40 0 100]
lassign $vals rows cols offsetx offsety pitchx pitchy

set inst1 [$block findInst "dat_ram"]
puts "setting the location of data_ram"
set x [expr round( ($offsetx * $units ) )]
set y [expr round( ($offsety * $units ) )]
$inst1 setOrigin $x $y
$inst1 setPlacementStatus FIRM

set inst2 [$block findInst "tag_ram"]
puts "setting the location of tag_ram"
set x [expr round( (300 * $units ) )]
set y [expr round( (($offsety + 620 + $pitchy) * $units ) )]
$inst2 setOrigin $x $y
$inst2 setPlacementStatus FIRM