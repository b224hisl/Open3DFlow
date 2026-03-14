#-----------------------------------------------------
# Tech/Libs
#   TRACK_OPTION - 9t 7t
#   METAL_OPTION - 5LM_1TM
#----------------------------------------------------
export TRACK_OPTION                          ?= 9t
export METAL_OPTION                          ?= 5LM_1TM
export KVALUE                                ?= 9
export POWER_OPTION                          ?= 5v0
export CORNER                                ?= BC
export PROCESS                                = 180

#----------------------------------------------------
# OpenROAD
#---------------------------------------------------- # 5LM_1TM_9K_9t_tech.lef
export TECH_LEF                               ?= $(PLATFORM_DIR)/lef/package_tech.lef

export GDS_FILES                              = $(wildcard $(PLATFORM_DIR)/gds/$(TRACK_OPTION)/*.gds) \
                                                $(ADDITIONAL_GDS)

# Dont use cells 
export DONT_USE_CELLS                         = 

# Fill cells used in fill cell insertion
export FILL_CELLS                             = 

export TIE_CELL                               = 
export ENDCAP_CELL                            = 
export RC_FILE                                = $(PLATFORM_DIR)/setRC.tcl

#-----------------------------------------------------
# Yosys
#-----------------------------------------------------

# set the TIEHI/TIELO cells
export TIEHI_CELL_AND_PORT                    = 
export TIELO_CELL_AND_PORT                    = 

export ABC_DRIVER_CELL                        = 
export ABC_LOAD_IN_FF                         = 

# hold buffer cell
export MIN_BUF_CELL_AND_PORTS                 = 

# Used in synthesis
export MAX_FANOUT                             = 20

#--------------------------------------------------------
# Floorplan
#-------------------------------------------------------
# Placement site for core cells
export PLACE_SITE                             = PACKAGE

# Define default PDN config
export PDN_TCL                               ?= 

# Endcap and Welltie cells
export TAPCELL_TCL                            ?= 

# macro planning
export MACRO_PLACE_HALO                      ?= 1 1
export MACRO_PLACE_CHANNEL                   ?= 2 2

#---------------------------------------------------------
# Place
#--------------------------------------------------------
# Cell padding in SITE widths to ease rout-ability.  Applied to both sides
export CELL_PAD_IN_SITES_GLOBAL_PLACEMENT    ?= 2
export CELL_PAD_IN_SITES_DETAIL_PLACEMENT    ?= 1

# global placement density
export PLACE_DENSITY                         ?= 0.40

#--------------------------------------------------------
# CTS
#--------------------------------------------------------
export CTS_BUF_CELL                           = 
export CTS_BUF_DISTANCE                       = 

#---------------------------------------------------------
# Route
#---------------------------------------------------------
# FastRoute options
export MIN_ROUTING_LAYER                     ?= L5_h
export MAX_ROUTING_LAYER                     ?= L1
export VIA_IN_PIN_MIN_LAYER                  ?= L1
export VIA_IN_PIN_MAX_LAYER                  ?= L5_h
export DISABLE_VIA_GEN                       ?= 1

# KLayout layer properties
export KLAYOUT_TECH_FILE                      = 
export KLAYOUT_LEF_FILE                       = 
export GDS_LAYER_MAP                          = 

# For RCX
export BC_RCX_RULES                           = 
export WC_RCX_RULES                           = 
export TC_RCX_RULES                           = 

export BC_RCX_RC_CORNER                       = 
export WC_RCX_RC_CORNER                       = 
export TC_RCX_RC_CORNER                       = 

export RCX_RULES                              = 
export RCX_RC_CORNER                          = 

#----------------------------------------------------------------------------------------------------
# define libraries - corner dependant setting
#----------------------------------------------------------------------------------------------------
# standard cell section
export LIB_FILES                             = $(ADDITIONAL_LIBS)

