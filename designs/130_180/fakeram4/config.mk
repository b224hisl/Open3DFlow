export DESIGN_NICKNAME = fakeram4
export DESIGN_NAME = dmem
export PLATFORM    = gf180
export MOTHER_PLATFORM = 130_180
export PLACE_DENSITY          = 0.7


export VERILOG_FILES = ./designs/src/riscv32i_3d/dmem_real
export SDC_FILE      = ./designs/$(MOTHER_PLATFORM)/$(DESIGN_NICKNAME)/constraint.sdc

export DIE_AREA = 0 0 1200 1000
export CORE_AREA = 20 20 1180 980


BLOCKS = gf180mcu_fd_ip_sram__sram256x8m8wm1

export MACRO_PLACEMENT_TCL = ./designs/$(MOTHER_PLATFORM)/$(DESIGN_NICKNAME)/macro.tcl

export MACRO_PLACE_HALO    = 1 1
export MACRO_PLACE_CHANNEL = 0 0


export PDN_TCL = ./designs/$(MOTHER_PLATFORM)/$(DESIGN_NICKNAME)/pdn.tcl


export GPL_ROUTABILITY_DRIVEN = 1

export IS_CHIP = 1

export MIN_ROUTING_LAYER = Metal1
export MAX_ROUTING_LAYER = Metal3

export MOTHER = riscv32i_3d
export MOTHER_PDK = 130_180

export IO_CONSTRAINTS = ./designs/$(MOTHER_PLATFORM)/$(DESIGN_NICKNAME)/pad_placer.tcl