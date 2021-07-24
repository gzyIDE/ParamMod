#!/bin/tcsh

set tcl_dir = `pwd`/xilinx
source ./target.sh
if ( $# =~ 0 ) then
	set TOP_MODULE = $DEFAULT_DESIGN
else
	set TOP_MODULE = $1
endif
cd ./xilinx/${TOP_MODULE}/${TOP_MODULE}.sim/sim_1/behav/xsim

# open wave database
xsim ${TOP_MODULE}_test_behav.wdb -gui

#xsim \
#	--gui \
#	--tclbatch ${tcl_dir}/xview.tcl
