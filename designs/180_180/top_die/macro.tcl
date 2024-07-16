set block [ord::get_db_block]
set units [$block getDefUnits]
# set vals [list 1 2 80 80 620 0]
# lassign $vals rows cols offsetx offsety pitchx pitchy

set inst0 [$block findInst "data_ram_0"]
puts "setting the location of data ram0"
set x0 [expr round( (80 * $units ) )]
set y0 [expr round( (80 * $units ) )]
$inst0 setOrigin $x0 $y0
$inst0 setPlacementStatus FIRM

set inst1 [$block findInst "data_ram_1"]
puts "setting the location of data ram1"
set x1 [expr round( (2120 * $units ) )]
set y1 [expr round( (80 * $units ) )]
$inst1 setOrigin $x1 $y1
$inst1 setPlacementStatus FIRM

set inst2 [$block findInst "tag_ram_0"]
puts "setting the location of tag ram0"
set x2 [expr round( (80 * $units ) )]
set y2 [expr round( (800 * $units ) )]
$inst2 setOrigin $x2 $y2
$inst2 setPlacementStatus FIRM

set inst3 [$block findInst "tag_ram_1"]
puts "setting the location of tag ram1"
set x3 [expr round( (2520 * $units ) )]
set y3 [expr round( (800 * $units ) )]
$inst3 setOrigin $x3 $y3
$inst3 setPlacementStatus FIRM