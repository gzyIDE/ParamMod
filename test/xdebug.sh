#!/bin/tcsh

# Integrated Waveform viewer and debugger

source ./target.sh
if ( $# =~ 0 ) then
	set TOP_MODULE = $DEFAULT_DESIGN
else
	set TOP_MODULE = $1
endif

vivado \
	./xilinx/${TOP_MODULE}/${TOP_MODULE}.xpr \
	-source ./xilinx/xdebug.tcl
