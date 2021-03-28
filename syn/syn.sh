#!/bin/tcsh

###########################################
########         Synthesis         ########
###########################################

if ( $#argv == 0 ) then
	# design name
	set DESIGN_NAME = cam
else
	set DESIGN_NAME = $1
endif

# constant parameter
set TCL_DIR	= "tcl"
set LOG_DIR = "log"
set REPORT_DIR = "report"
set RESULT_DIR = "result"

# tool settings
if ( $#argv <= 1 ) then
	set TOOL = dc_shell
	#set TOOL = genus
else
	set TOOL = $2
endif

mkdir -p ${LOG_DIR}
mkdir -p ${RESULT_DIR}
mkdir -p ${REPORT_DIR}
mkdir -p ${RESULT_DIR}/${DESIGN_NAME}
mkdir -p ${REPORT_DIR}/${DESIGN_NAME}

if ( $TOOL == "dc_shell" ) then
	dc_shell -f ${TCL_DIR}/${DESIGN_NAME}.tcl | tee ${LOG_DIR}/${DESIGN_NAME}.dc.log
else if ( $TOOL == "genus" ) then
	genus -f ${TCL_DIR}/${DESIGN_NAME}.tcl | tee ${LOG_DIR}/${DESIGN_NAME}.genus.log
endif
