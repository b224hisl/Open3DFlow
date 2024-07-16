# this tcl is used to write the location of specific pins, generating pin location file
# Helper function to split a string into a list of strings and numbers
proc split_strings_and_numbers {str} {
    set result {}
    foreach {all letters numbers} [regexp -all -inline {(\D*)(\d*)} $str] {
        if {$letters ne ""} {
            lappend result $letters
        }
        if {$numbers ne ""} {
            lappend result [expr {$numbers + 0}]  ;# Convert to integer
        }
    }
    return $result
}

# Custom comparison function
proc natural_compare {str1 str2} {
    set list1 [split_strings_and_numbers $str1]
    set list2 [split_strings_and_numbers $str2]
    set len [expr {min([llength $list1], [llength $list2])}]
    for {set i 0} {$i < $len} {incr i} {
        set part1 [lindex $list1 $i]
        set part2 [lindex $list2 $i]
        if {$part1 ne $part2} {
            if {[string is integer -strict $part1] && [string is integer -strict $part2]} {
                return [expr {$part1 - $part2}]
            } else {
                return [string compare $part1 $part2]
            }
        }
    }
    return [expr {[llength $list1] - [llength $list2]}]  ;# If all parts are equal, compare by length
}

proc natural_sort {list} {
    return [lsort -command natural_compare $list]
}

proc match_pins { regex } {
    set pins {}
    # The regex for get_ports is not the tcl regex
    foreach pin [get_ports -regex .*] {
        set input [get_property $pin name]
        # We want the Tcl regex
        if {![regexp $regex $input]} {
            continue
        }
        lappend pins [get_property $pin name]
    }
    return [natural_sort $pins]
}

########### bonding pad location #################
puts "begin generation bonding pad location file"
# cluster1
set icache_valid_o [match_pins icache_valid_o]
set icache_addr_o [match_pins icache_addr_o]
set cluster1 [concat $icache_valid_o $icache_addr_o]
set cluster1_locname "$::env(RESULTS_DIR)/cluster1.txt"
set cluster1_loc [open $cluster1_locname "w"]

foreach c1 $cluster1 {
    puts "c1=$c1"
    set port [get_ports $c1]
    set port_loc [sta::port_location $port]
    set x [expr {[lindex $port_loc 0] * 1000000}]
    set y [expr {[lindex $port_loc 1] * 1000000}]
    puts $cluster1_loc "$x $y"
}
close $cluster1_loc

# cluster2
set icache_valid_i [match_pins icache_valid_i]
set icache_dat_i [match_pins icache_dat_i]
set cluster2 [concat $icache_valid_i $icache_dat_i]
set cluster2_locname "$::env(RESULTS_DIR)/cluster2.txt"
set cluster2_loc [open $cluster2_locname "w"]

foreach c2 $cluster2 {
    puts "c2=$c2"
    set port [get_ports $c2]
    set port_loc [sta::port_location $port]
    set x [expr {[lindex $port_loc 0] * 1000000}]
    set y [expr {[lindex $port_loc 1] * 1000000}]
    puts $cluster2_loc "$x $y"
}
close $cluster2_loc

# prerequist
set dcache_dat_o [match_pins dcache_dat_o]

# cluster3
set dcache_valid_o [match_pins dcache_valid_o]
set dcache_we_o [match_pins dcache_we_o]
set dcache_addr_o [match_pins dcache_addr_o]
set dcache_dat_o_low [lrange $dcache_dat_o 0 14]
set cluster3 [concat $dcache_valid_o $dcache_we_o $dcache_addr_o $dcache_dat_o_low]
set cluster3_locname "$::env(RESULTS_DIR)/cluster3.txt"
set cluster3_loc [open $cluster3_locname "w"]

foreach c3 $cluster3 {
    puts "c3=$c3"
    set port [get_ports $c3]
    set port_loc [sta::port_location $port]
    set x [expr {[lindex $port_loc 0] * 1000000}]
    set y [expr {[lindex $port_loc 1] * 1000000}]
    puts $cluster3_loc "$x $y"
}
close $cluster3_loc

# cluster4
set dcache_valid_i [match_pins dcache_valid_i]
set dcache_dat_i [match_pins dcache_dat_i]
set dcache_dat_o_high [lrange $dcache_dat_o 15 31]
set cluster4 [concat $dcache_valid_i $dcache_dat_i $dcache_dat_o_high]
set cluster4_locname "$::env(RESULTS_DIR)/cluster4.txt"
set cluster4_loc [open $cluster4_locname "w"]

foreach c4 $cluster4 {
    puts "c4=$cluster4"
    set port [get_ports $c4]
    set port_loc [sta::port_location $port]
    set x [expr {[lindex $port_loc 0] * 1000000}]
    set y [expr {[lindex $port_loc 1] * 1000000}]
    puts $cluster4_loc "$x $y"
}
close $cluster4_loc

puts "end generating pin location file"
