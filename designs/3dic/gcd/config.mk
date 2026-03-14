export DESIGN_NAME = gcd
export PLATFORM    = sky130hd

export VERILOG_FILES = ./designs/src/$(DESIGN_NICKNAME)/gcd.v
export SDC_FILE      = ./designs/$(PLATFORM)/$(DESIGN_NICKNAME)/constraint.sdc

# Adders degrade GCD
export ADDER_MAP_FILE :=

export CORE_UTILIZATION = 40
export TNS_END_PERCENT = 100
export EQUIVALENCE_CHECK   ?=   1
export REMOVE_CELLS_FOR_EQY = sky130_fd_sc_hd__tapvpwrvgnd*

# export PWR_NETS_VOLTAGES := "VPWRIN 1.8"
# export GND_NETS_VOLTAGES = "VSS 0.0 VNB 0.0 VGND 0.0"

