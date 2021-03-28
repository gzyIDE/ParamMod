#/bin/tcsh

###############################################
########     Formal Verification     ##########
###############################################

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
if ( $#argv == 0 || $#argv == 1 ) then
	set TOOL = fm_shell
else
	set TOOL = $2
endif

mkdir -p ${LOG_DIR}
mkdir -p ${RESULT_DIR}
mkdir -p ${REPORT_DIR}
mkdir -p ${RESULT_DIR}/${DESIGN_NAME}
mkdir -p ${REPORT_DIR}/${DESIGN_NAME}

if ( $TOOL == "fm_shell" ) then
	fm_shell -f ${TCL_DIR}/${DESIGN_NAME}.tcl | tee ${LOG_DIR}/fm_${DESIGN_NAME}.log
else if ( $TOOL == "comformal" ) then
	# conformal ( not installed yet )
endif
