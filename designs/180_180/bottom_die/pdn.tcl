####################################
# global connections
####################################
add_global_connection -net {VDD} -inst_pattern {.*} -pin_pattern {^VDD$} -power
add_global_connection -net {VDD} -inst_pattern {.*} -pin_pattern {^VDDPE$}
add_global_connection -net {VDD} -inst_pattern {.*} -pin_pattern {^VDDCE$}
add_global_connection -net {VDD} -inst_pattern {.*} -pin_pattern {^VDDP$}
add_global_connection -net {VDD} -inst_pattern {.*} -pin_pattern {^VDDC$}
add_global_connection -net {VDD} -inst_pattern {.*} -pin_pattern {^VNW$}
add_global_connection -net {VSS} -inst_pattern {.*} -pin_pattern {^VSS$} -ground
add_global_connection -net {VSS} -inst_pattern {.*} -pin_pattern {^VSSE$}
add_global_connection -net {VSS} -inst_pattern {.*} -pin_pattern {^VSSC$}
add_global_connection -net {VSS} -inst_pattern {.*} -pin_pattern {^VPW$}
####################################
# voltage domains
####################################
set_voltage_domain -name {CORE} -power {VDD} -ground {VSS}
####################################
# standard cell grid
####################################
define_pdn_grid -name {block} -voltage_domains {CORE}
add_pdn_stripe -grid {block} -layer {Metal1} -width {0.900} -pitch {5.040} -offset {0} -followpins
add_pdn_stripe -grid {block} -layer {Metal4} -width {4.480} -spacing {0.56} -pitch {100} -offset {12}
#add_pdn_stripe -grid {block} -layer {Metal5} -width {4.480} -pitch {89.6} -offset {44.8}
add_pdn_connect -grid {block} -layers {Metal1 Metal4} -max_columns {5} -ongrid {Metal2 Metal3 Metal4} -split_cuts {Metal3 0.128}
#add_pdn_connect -grid {block} -layers {Metal4 Metal5}
