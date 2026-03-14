# 这是边边的，小框
export DESIGN_NICKNAME = soc_ddr_connect
export DESIGN_NAME = soc_ddr
export PLATFORM    = package

export VERILOG_FILES = ./designs/src/bump.v
export SDC_FILE      = ./designs/$(PLATFORM)/$(DESIGN_NICKNAME)/constraint.sdc
#export TECH_LEF = ./designs/$(PLATFORM)/$(DESIGN_NICKNAME)/package_explore.lef

export DIE_AREA = 0 0 34500 34500
export CORE_AREA = 1 1 34499 34499
# export CORE_UTILIZATION = 20
export ADDITIONAL_LEFS = ./designs/$(PLATFORM)/$(DESIGN_NICKNAME)/ddr.lef \
							./designs/$(PLATFORM)/$(DESIGN_NICKNAME)/soc.lef

export PDN_TCL = ./designs/$(PLATFORM)/$(DESIGN_NICKNAME)/pdn.tcl

export DONT_BUFFER_PORTS = 1
# export BALANCE_ROWS = 1
export CELL_PAD_IN_SITES_GLOBAL_PLACEMENT    = 0 
export CELL_PAD_IN_SITES_DETAIL_PLACEMENT    = 0
# (原本生成，带了new的是去掉了外部链接)
# export NETLIST_CUST = ./designs/$(PLATFORM)/$(DESIGN_NICKNAME)/soc_ddr.v
export NETLIST_CUST = ./designs/$(PLATFORM)/$(DESIGN_NICKNAME)/soc_ddr_l5.v
export IO_PLACER_H                           = L3_h
export IO_PLACER_V                           = L3_v
export TAPCELL_TCL = ./designs/$(PLATFORM)/$(DESIGN_NICKNAME)/tapcell.tcl
export PACKAGE = 1
export MACRO_PLACEMENT_TCL = ./designs/$(PLATFORM)/$(DESIGN_NICKNAME)/macro.tcl
# export FLOORPLAN_DEF = ./results/gf180/soc_ddr_connect/20251228/6_final.def
export IO_CONSTRAINTS = ./designs/$(PLATFORM)/$(DESIGN_NICKNAME)/io.tcl
export MAX_ROUTING_LAYER = L5_v
export MIN_ROUTING_LAYER = L5_h
export ADDITIONAL_LIBS = ./designs/$(PLATFORM)/$(DESIGN_NICKNAME)/package.lib
export MAKE_TRACKS = ./designs/$(PLATFORM)/$(DESIGN_NICKNAME)/tracks.tcl
export SKIP_INCREMENTAL_REPAIR = 1
export SKIP_ANTENNA_REPAIR = 1
export SKIP_ANTENNA_REPAIR_POST_DRT = 1

export FLOW_VARIANT = L5_small