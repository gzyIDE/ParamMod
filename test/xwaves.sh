#!/bin/tcsh

source ./target.sh
if ( $# =~ 0 ) then
	set TOP_MODULE = $DEFAULT_DESIGN
else
	set TOP_MODULE = $1
endif

xsim \
	--gui \
	--tclbatch xview.tcl \
	${TOP_MODULE}_test
