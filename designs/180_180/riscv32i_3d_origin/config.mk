export DESIGN_NICKNAME = riscv32i_3d
export DESIGN_NAME = core_without_dmem
# top = dmem + core_without_dmem
export PLATFORM    = 180_180
export PLACE_DENSITY          = 0.5

export SYNTH_HIERARCHICAL = 1
export RTLMP_FLOW = True
export MAX_UNGROUP_SIZE ?= 1000

export VERILOG_FILES = $(sort $(wildcard ./designs/src/riscv32i_3d/*.v))
export SDC_FILE      = ./designs/130_180/$(DESIGN_NICKNAME)/constraint.sdc


export DIE_AREA = 0 0 1200 1000
export CORE_AREA = 20 20 1180 980

export PLACE_DENSITY_LB_ADDON = 0.12

export MACRO_PLACE_HALO    = 1 1
export MACRO_PLACE_CHANNEL = 6 6
#
export TNS_END_PERCENT   = 100
export MIN_ROUTING_LAYER = Metal1
export MAX_ROUTING_LAYER = Metal4

export IO_CONSTRAINTS = ./designs/$(PLATFORM)/$(DESIGN_NICKNAME)/io.tcl
export IS_CHIP = 1
export MOTHER_PIN_GEN = ./designs/$(PLATFORM)/$(DESIGN_NICKNAME)/pad_gen.tcl
export TSV_DELAY = 0.03
export PDN_TCL = ./designs/$(PLATFORM)/$(DESIGN_NICKNAME)/pdn.tcl

export REPAIR_PDN_VIA_LAYER = 1
