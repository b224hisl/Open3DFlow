export DESIGN_NICKNAME = bottom_die
export DESIGN_NAME = bottem_die
export PLATFORM    = 180_180
export PLACE_DENSITY          = 0.4

BLOCKS = L1d \
		L1i

export MACRO_FOLDER = bottom_macro
export MACRO_PLACEMENT_TCL = ./designs/$(PLATFORM)/$(DESIGN_NICKNAME)/macro.tcl

export DIE_AREA = 0 0 3220 2220
export CORE_AREA = 10 10 3210 2210
export VERILOG_FILES = ./designs/src/$(DESIGN_NICKNAME)/*.v
export SDC_FILE      = ./designs/$(PLATFORM)/$(DESIGN_NICKNAME)/constraint.sdc

export MACRO_PLACE_HALO    = 1 1
export MACRO_PLACE_CHANNEL = 0 0

export GPL_TIMING_DRIVEN = 1

export IS_CHIP = 1

export MIN_ROUTING_LAYER = Metal1
export MAX_ROUTING_LAYER = Bonding_layer
# export VIA_IN_PIN_MAX_LAYER = Bonding_layer
# export REPAIR_PDN_VIA_LAYER = 1

export IO_CONSTRAINTS = ./designs/$(PLATFORM)/$(DESIGN_NICKNAME)/pad_random.tcl
export MOTHER_PIN_GEN = ./designs/$(PLATFORM)/$(DESIGN_NICKNAME)/pad_gen.tcl
export PDN_TCL = ./designs/$(PLATFORM)/$(DESIGN_NICKNAME)/pdn.tcl

