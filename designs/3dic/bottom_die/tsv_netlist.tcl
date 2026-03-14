set num_tsv $::env(TSV_NUM)

set input_filename "$::env(RESULTS_DIR)/1_synth.v"
set output_filename "$::env(RESULTS_DIR)/1_tsv.v"
if {[file exists $output_filename]} {
    file delete -force $output_filename
}

set fp [open $input_filename r]
set content [read $fp]
close $fp

set lines [split $content "\n"]

set insert_content ""
for {set i 0} {$i < $num_tsv} {incr i} {
    append insert_content "\n  tsv tsv_$i (\n \n  );"
}

set new_lines [linsert $lines end-2 $insert_content]

set fp [open $output_filename w]
puts -nonewline $fp [join $new_lines "\n"]
close $fp

puts "Successfully inserted $num_tsv tsv module instances into the file $output_filename"