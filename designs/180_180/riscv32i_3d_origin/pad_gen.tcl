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

########### pin location #################
puts "begin generation pin location file"
# writedata
set writedata [match_pins writedata*]
set writedata_locname "$::env(RESULTS_DIR)/writedata_loca.txt"
set writedata_loc [open $writedata_locname "w"]

foreach wd $writedata {
    puts "wd=$wd"
    set port [get_ports $wd]
    set port_loc [sta::port_location $port]
    set x [expr {[lindex $port_loc 0] * 1000000}]
    set y [expr {[lindex $port_loc 1] * 1000000}]
    puts $writedata_loc "$x $y"
}
close $writedata_loc

# dataadr
set dataadr [match_pins dataadr*]
set dataadr_locname "$::env(RESULTS_DIR)/dataadr_loca.txt"
set dataadr_loc [open $dataadr_locname "w"]

foreach da $dataadr {
    puts "dataadr=$da"
    set port [get_ports $da]
    set port_loc [sta::port_location $port]
    set x [expr {[lindex $port_loc 0] * 1000000}]
    set y [expr {[lindex $port_loc 1] * 1000000}]
    puts $dataadr_loc "$x $y"
}
close $dataadr_loc

# inter_dmem
set inter_dmem [match_pins inter_dmem*]
set inter_dmem_locname "$::env(RESULTS_DIR)/inter_dmem_loca.txt"
set inter_dmem_loc [open $inter_dmem_locname "w"]

foreach id $inter_dmem {
    puts "inter_dmem=$id"
    set port [get_ports $id]
    set port_loc [sta::port_location $port]
    set x [expr {[lindex $port_loc 0] * 1000000}]
    set y [expr {[lindex $port_loc 1] * 1000000}]
    puts $inter_dmem_loc "$x $y"
}
close $inter_dmem_loc

# ce_mem/we_mem
set e_mem [match_pins e_mem*]
set e_mem_locname "$::env(RESULTS_DIR)/e_mem_loca.txt"
set e_mem_loc [open $e_mem_locname "w"]

foreach em $e_mem {
    puts "e_mem=$em"
    set port [get_ports $em]
    set port_loc [sta::port_location $port]
    set x [expr {[lindex $port_loc 0] * 1000000}]
    set y [expr {[lindex $port_loc 1] * 1000000}]
    puts $e_mem_loc "$x $y"
}
close $e_mem_loc

puts "end generating pin location file"
