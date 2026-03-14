export DESIGN_NICKNAME = bottom_die
export DESIGN_NAME = bottem_die
export PLATFORM    = 3dic
export PLACE_DENSITY          = 0.4

BLOCKS = L1d \
		L1i

export MACRO_FOLDER = ./designs/$(PLATFORM)/$(DESIGN_NICKNAME)/bottom_macro
export MACRO_PLACEMENT_TCL = ./designs/$(PLATFORM)/$(DESIGN_NICKNAME)/macro.tcl

export DIE_AREA = 0 0 3220 2220
export CORE_AREA = 10 10 3210 2210
export VERILOG_FILES = ./designs/src/$(DESIGN_NICKNAME)/*.v
export SDC_FILE      = ./designs/$(PLATFORM)/$(DESIGN_NICKNAME)/constraint.sdc

export MACRO_PLACE_HALO    = 1 1
export MACRO_PLACE_CHANNEL = 0 0

export GPL_TIMING_DRIVEN = 1

export IS_CHIP = 0

export PDN_TCL = ./designs/$(PLATFORM)/$(DESIGN_NICKNAME)/pdn.tcl


# 3D IC RELATED
export MIN_ROUTING_LAYER = Metal1
#bonding layer
export MAX_ROUTING_LAYER = Metal4
export Bonding_layer = BONDING_LAYER
# export VIA_IN_PIN_MAX_LAYER = Bonding_layer
# export REPAIR_PDN_VIA_LAYER = 1
export PWR_NETS_VOLTAGES := "VDD 5.5"
export GND_NETS_VOLTAGES = "VSS 0.0"
export SKIP_ANTENNA_REPAIR_POST_DRT = 1
export IR_DROP_LAYER = "Metal1 Metal2 Metal3 Metal4 BONDING_LAYER"

# HB PAD
export IO_CONSTRAINTS = ./designs/$(PLATFORM)/$(DESIGN_NICKNAME)/pad.tcl
export MOTHER_PIN_GEN = ./designs/$(PLATFORM)/$(DESIGN_NICKNAME)/pad_gen.tcl

# # TSV-related
# # produce tsv.v before floorplan begin (floorplan.tcl)
# export TSV_INSERT_SCRIPT = ./designs/$(PLATFORM)/$(DESIGN_NICKNAME)/tsv_netlist.tcl
# export ADDITIONAL_LEFS = ./designs/$(PLATFORM)/$(DESIGN_NICKNAME)/tsv_4LM_1TM_9K_9t.lef
# export ADDITIONAL_LIBS = ./designs/$(PLATFORM)/$(DESIGN_NICKNAME)/power_tsv.lib
# export 3DIC = 1
# export GDS_ALLOW_EMPTY = tsv
# export TSV_NUM = 10
# export TSV_SIZE = 30.24
# export TSV_PEN = 5
# # tsv setting & power supply, after global place (global_place.tcl)
# export TSV_SET_SCRIPT = ./designs/$(PLATFORM)/$(DESIGN_NICKNAME)/tsv_set.tcl
# export TSV_LOC = ./designs/$(PLATFORM)/$(DESIGN_NICKNAME)/tsv.loc
# # tsv hole insert obstruction, before cts (cts.tcl)
# export TSV_HOLE = ./designs/$(PLATFORM)/$(DESIGN_NICKNAME)/tsv_hole.tcl



