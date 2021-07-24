# Initialize design configuration
source ./xilinx/top.tcl
source ./xilinx/${TOP}/files.tcl
source ./xilinx/${TOP}/defines.tcl
set TEST_MODULE ${TOP}_test

set_property verilog_define ${DEFINE_LISTS} [get_filesets sim_1]
set_property top ${TOP}_test [get_filesets sim_1]
