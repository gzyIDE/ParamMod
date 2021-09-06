#!/bin/tcsh

# Files and Directories Settings
set TOPDIR = `pwd`"/.."
set RTLDIR = "${TOPDIR}/rtl"
set TESTDIR = "${TOPDIR}/test"
set TBDIR = "${TESTDIR}/tb"
set TESTINCDIR = "${TESTDIR}/include"
set GATEDIR = "${TOPDIR}/syn/result"
set SV2VDIR = "${TOPDIR}/sv2v"
set SV2VRTLDIR = "${SV2VDIR}/rtl"
set SV2VTESTDIR = "${SV2VDIR}/test"

# Include
set INCDIR = ( \
	${TOPDIR}/include \
	${TESTINCDIR} \
)

# Define
set DEFINE_LIST = ( \
	SIMULATION \
	MEM_FILE=\\\"${TESTDIR}/sample.mem\\\" \
)

# Caution
#	If you use vivado, current directory is ./xilinx/${design}.
#	But other tools (xmverilog or vcs) use . as current directory.
#	So, file path should be written in absolute path, instead of relative.
