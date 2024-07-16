export DESIGN_NICKNAME = 2small
export DESIGN_NAME = mem_64_16_gf180
export PLATFORM    = gf180
export PLACE_DENSITY          = 0.7

BLOCKS = gf180mcu_fd_ip_sram__sram64x8m8wm1

export MACRO_FOLDER = gf180sram
export MACRO_PLACEMENT_TCL = ./designs/$(PLATFORM)/$(DESIGN_NICKNAME)/macro.tcl

export DIE_AREA = 0 0 620 620
export CORE_AREA = 10 10 610 610
export VERILOG_FILES = ./designs/src/riscv32i_3d/cache/mem_64_16_gf180.v
export SDC_FILE      = ./designs/$(PLATFORM)/$(DESIGN_NICKNAME)/constraint.sdc

export MACRO_PLACE_HALO    = 1 1
export MACRO_PLACE_CHANNEL = 0 0

export GPL_ROUTABILITY_DRIVEN = 1

export IS_CHIP = 1

export MIN_ROUTING_LAYER = Metal1
export MAX_ROUTING_LAYER = Metal4

export RENAME_SCRIPT = ./designs/$(PLATFORM)/$(DESIGN_NICKNAME)