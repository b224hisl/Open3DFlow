if {[env_var_exists_and_non_empty FLOORPLAN_DEF]} {
    puts "Skipping IO placement as DEF file was used to initialize floorplan."
} else {
    if {[env_var_exists_and_non_empty IO_CONSTRAINTS]} {
      source $::env(IO_CONSTRAINTS)
      if {[info exists ::env(MOTHER_PIN_GEN)]} {  
          source $::env(MOTHER_PIN_GEN)  
      }  
    } else {
    set args [list -hor_layers $::env(IO_PLACER_H) \
            -ver_layers $::env(IO_PLACER_V) \
            {*}$::env(PLACE_PINS_ARGS)]
    log_cmd place_pins {*}$args
          }
      }
