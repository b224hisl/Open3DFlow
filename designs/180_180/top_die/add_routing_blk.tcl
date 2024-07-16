set db [::ord::get_db]
set block [[$db getChip] getBlock]
set tech [$db getTech]

set layer_M4 [$tech findLayer Metal4]
set obs1 [odb::dbObstruction_create $block $layer_M4 1590 1840 1610 2017]
set obs2 [odb::dbObstruction_create $block $layer_M4 1907 1844 1968 1889]
puts "Rouing blockages have been added to the design flow"