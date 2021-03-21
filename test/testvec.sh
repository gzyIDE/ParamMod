#!/bin/tcsh

#######################################
##### File and Directory Settings #####
#######################################
set TOPDIR = ".."
set RTLDIR = "${TOPDIR}/rtl"
set TESTDIR = "${TOPDIR}/test"
set GATEDIR = "${TOPDIR}/syn/result"
set INCDIR = ( \
	${TOPDIR}/include \
	${TESTDIR} \
)
set INCLUDE = ()
set DEFINES = ()

#############################################
# Output Wave
#############################################
set Waves = 1
set WaveOpt

#############################################
# Defines
#############################################
if ( $Waves =~ 1 ) then
	set DEFINE_LIST = ( WAVE_DUMP )
else 
	set DEFINE_LIST = ()
endif

#############################################
#           Gate Level Simulation           #
#############################################
#set GATE = 1
set GATE = 0
if ( $GATE =~ 1 ) then
	set DEFINE_LIST = ($DEFINE_LIST NETLIST)
endif

#############################################
#              Process Setting              #
#############################################
#set Process = "ASAP7"
set Process = "None"

switch ($Process)
	case "ASAP7" :
		set CELL_LIB = "./ASAP7_PDKandLIB_v1p6/lib_release_191006"
		set CELL_RTL_DIR = "${CELL_LIB}/asap7_7p5t_library/rev25/Verilog"
		set DEFINE_LIST = (${DEFINE_LIST} ASAP7)

		set RTL_FILE = ( \
			-v $CELL_RTL_DIR/asap7sc7p5t_AO_RVT_TT_08302018.v \
			-v $CELL_RTL_DIR/asap7sc7p5t_AO_LVT_TT_08302018.v \
			-v $CELL_RTL_DIR/asap7sc7p5t_AO_SLVT_TT_08302018.v \
			-v $CELL_RTL_DIR/asap7sc7p5t_AO_SRAM_TT_08302018.v \
			-v $CELL_RTL_DIR/asap7sc7p5t_INVBUF_RVT_TT_08302018.v \
			-v $CELL_RTL_DIR/asap7sc7p5t_INVBUF_LVT_TT_08302018.v \
			-v $CELL_RTL_DIR/asap7sc7p5t_INVBUF_SLVT_TT_08302018.v \
			-v $CELL_RTL_DIR/asap7sc7p5t_INVBUF_SRAM_TT_08302018.v \
			-v $CELL_RTL_DIR/asap7sc7p5t_OA_RVT_TT_08302018.v \
			-v $CELL_RTL_DIR/asap7sc7p5t_OA_LVT_TT_08302018.v \
			-v $CELL_RTL_DIR/asap7sc7p5t_OA_SLVT_TT_08302018.v \
			-v $CELL_RTL_DIR/asap7sc7p5t_OA_SRAM_TT_08302018.v \
			-v $CELL_RTL_DIR/asap7sc7p5t_SEQ_RVT_TT_08302018.v \
			-v $CELL_RTL_DIR/asap7sc7p5t_SEQ_LVT_TT_08302018.v \
			-v $CELL_RTL_DIR/asap7sc7p5t_SEQ_SLVT_TT_08302018.v \
			-v $CELL_RTL_DIR/asap7sc7p5t_SEQ_SRAM_TT_08302018.v \
			-v $CELL_RTL_DIR/asap7sc7p5t_SIMPLE_RVT_TT_08302018.v \
			-v $CELL_RTL_DIR/asap7sc7p5t_SIMPLE_LVT_TT_08302018.v \
			-v $CELL_RTL_DIR/asap7sc7p5t_SIMPLE_SLVT_TT_08302018.v \
			-v $CELL_RTL_DIR/asap7sc7p5t_SIMPLE_SRAM_TT_08302018.v \
		)
	breaksw
	default :
		# Simulation with simple gate model (Process = "None")
		# Nothing to set
		set RTL_FILE = ()
	breaksw
endsw

########################################
#     Simulation Target Selection      #
########################################
source target.sh

if ( $# =~ 0 ) then
	set TOP_MODULE = $DEFAULT_DESIGN
else
	set TOP_MODULE = $1
endif

switch ( $TOP_MODULE )
	case "pri_enc" :
		set TEST_FILE = "${TOP_MODULE}_test.sv"
		if ( $GATE =~ 1 ) then
			set RTL_FILE = ( \
				$RTL_FILE \
				${GATEDIR}/${TOP_MODULE}/${TOP_MODULE}.mapped.v \
			)
		else
			set RTL_FILE = ( \
				${RTLDIR}/${TOP_MODULE}.sv \
			)
		endif
	breaksw

	case "cnt_bits" :
		set TEST_FILE = "${TOP_MODULE}_test.sv"
		if ( $GATE =~ 1 ) then
			set RTL_FILE = ( \
				$RTL_FILE \
				${GATEDIR}/${TOP_MODULE}/${TOP_MODULE}.mapped.v \
			)
		else
			set RTL_FILE = ( \
				${RTLDIR}/${TOP_MODULE}.sv \
			)
		endif
	breaksw

	case "bin_dec" :
		set TEST_FILE = "${TOP_MODULE}_test.sv"
		if ( $GATE =~ 1 ) then
			set RTL_FILE = ( \
				$RTL_FILE \
				${GATEDIR}/${TOP_MODULE}/${TOP_MODULE}.mapped.v \
			)
		else
			set RTL_FILE = ( \
				${RTLDIR}/${TOP_MODULE}.sv \
			)
		endif
	breaksw

	case "fifo" :
		set TEST_FILE = "${TOP_MODULE}_test.sv"
		if ( $GATE =~ 1 ) then
			set RTL_FILE = ( \
				$RTL_FILE \
				${GATEDIR}/${TOP_MODULE}/${TOP_MODULE}.mapped.v \
			)
		else
			set RTL_FILE = ( \
				${RTLDIR}/${TOP_MODULE}.sv \
				${RTLDIR}/cnt_bits.sv \
			)
		endif
	breaksw

	case "selector" :
		set TEST_FILE = "${TOP_MODULE}_test.sv"
		if ( $GATE =~ 1 ) then
			set RTL_FILE = ( \
				$RTL_FILE \
				${GATEDIR}/${TOP_MODULE}/${TOP_MODULE}.mapped.v \
			)
		else
			set RTL_FILE = ( \
				${RTLDIR}/${TOP_MODULE}.sv \
			)
		endif
	breaksw

	case "cam" :
		set TEST_FILE = "${TOP_MODULE}_test.sv"
		if ( $GATE =~ 1 ) then
			set RTL_FILE = ( \
				$RTL_FILE \
				${GATEDIR}/${TOP_MODULE}/${TOP_MODULE}.mapped.v \
			)
		else
			set RTL_FILE = ( \
				${RTLDIR}/${TOP_MODULE}.sv \
			)
		endif
	breaksw

	case "cam2" :
		set TEST_FILE = "${TOP_MODULE}_test.sv"
		if ( $GATE =~ 1 ) then
			set RTL_FILE = ( \
				$RTL_FILE \
				${GATEDIR}/${TOP_MODULE}/${TOP_MODULE}.mapped.v \
			)
		else
			set RTL_FILE = ( \
				${RTLDIR}/${TOP_MODULE}.sv \
				${RTLDIR}/selector.sv \
			)
		endif
	breaksw

	case "ring_buf" :
		set TEST_FILE = "${TOP_MODULE}_test.sv"
		if ( $GATE =~ 1 ) then
			set RTL_FILE = ( \
				$RTL_FILE \
				${GATEDIR}/${TOP_MODULE}/${TOP_MODULE}.mapped.v \
			)
		else
			set RTL_FILE = ( \
				${RTLDIR}/${TOP_MODULE}.sv \
				${RTLDIR}/cnt_bits.sv \
			)
		endif
	breaksw

	case "shifter" :
		set TEST_FILE = "${TOP_MODULE}_test.sv"
		if ( $GATE =~ 1 ) then
			set RTL_FILE = ( \
				$RTL_FILE \
				${GATEDIR}/${TOP_MODULE}/${TOP_MODULE}.mapped.v \
			)
		else
			set RTL_FILE = ( \
				${RTLDIR}/${TOP_MODULE}.sv \
				${RTLDIR}/cnt_bits.sv \
			)
		endif
	breaksw

	case "regfile" :
		set TEST_FILE = "${TOP_MODULE}_test.sv"
		if ( $GATE =~ 1 ) then
			set RTL_FILE = ( \
				$RTL_FILE \
				${GATEDIR}/${TOP_MODULE}/${TOP_MODULE}.mapped.v \
			)
		else
			set RTL_FILE = ( \
				${RTLDIR}/${TOP_MODULE}.sv \
			)
		endif
	breaksw

	case "freelist" :
		set TEST_FILE = "${TOP_MODULE}_test.sv"
		if ( $GATE =~ 1 ) then
			set RTL_FILE = ( \
				$RTL_FILE \
				${GATEDIR}/${TOP_MODULE}/${TOP_MODULE}.mapped.v \
			)
		else
			set RTL_FILE = ( \
				${RTLDIR}/${TOP_MODULE}.sv \
				${RTLDIR}/selector.sv \
				${RTLDIR}/cnt_bits.sv \
			)
		endif
	breaksw

	case "sel_minmax" :
		set TEST_FILE = "${TOP_MODULE}_test.sv"
		if ( $GATE =~ 1 ) then
			set RTL_FILE = ( \
				$RTL_FILE \
				${GATEDIR}/${TOP_MODULE}/${TOP_MODULE}.mapped.v \
			)
		else
			set RTL_FILE = ( \
				${RTLDIR}/${TOP_MODULE}.sv \
				${RTLDIR}/bin_dec.sv \
			)
		endif
	breaksw

	case "stack" :
		set TEST_FILE = "${TOP_MODULE}_test.sv"
		if ( $GATE =~ 1 ) then
			set RTL_FILE = ( \
				$RTL_FILE \
				${GATEDIR}/${TOP_MODULE}/${TOP_MODULE}.mapped.v \
			)
		else
			set RTL_FILE = ( \
				${RTLDIR}/${TOP_MODULE}.sv \
				${RTLDIR}/cnt_bits.sv \
			)
		endif
	breaksw

	case "reduct" :
		set TEST_FILE = "${TOP_MODULE}_test.sv"
		if ( $GATE =~ 1 ) then
			set RTL_FILE = ( \
				$RTL_FILE \
				${GATEDIR}/${TOP_MODULE}/${TOP_MODULE}.mapped.v \
			)
		else
			set RTL_FILE = ( \
				${RTLDIR}/${TOP_MODULE}.sv \
			)
		endif
	breaksw

	case "gather" :
		set TEST_FILE = "${TOP_MODULE}_test.sv"
		if ( $GATE =~ 1 ) then
			set RTL_FILE = ( \
				$RTL_FILE \
				${GATEDIR}/${TOP_MODULE}/${TOP_MODULE}.mapped.v \
			)
		else
			set RTL_FILE = ( \
				${RTLDIR}/${TOP_MODULE}.sv \
				${RTLDIR}/cnt_bits.sv \
				${RTLDIR}/selector.sv \
			)
		endif
	breaksw

	case "scatter" :
		set TEST_FILE = "${TOP_MODULE}_test.sv"
		if ( $GATE =~ 1 ) then
			set RTL_FILE = ( \
				$RTL_FILE \
				${GATEDIR}/${TOP_MODULE}/${TOP_MODULE}.mapped.v \
			)
		else
			set RTL_FILE = ( \
				${RTLDIR}/${TOP_MODULE}.sv \
				${RTLDIR}/cnt_bits.sv \
				${RTLDIR}/selector.sv \
			)
		endif
	breaksw

	default : 
		# Error
		echo "Invalid Module"
		exit 1
	breaksw
endsw


########################################
#        Simulation Tool Setup         #
########################################
source sim_tool.sh

switch( $SIM_TOOL )
	case "ncverilog" :
		if ( $Waves =~ 1 ) then
			set WaveOpt = +define+CADENCE
		endif

		set SIM_OPT = ( \
			+nc64bit \
			$WaveOpt \
			+access+r \
			+notimingchecks \
			-ALLOWREDEFINITION \
		)
		set SRC_EXT = ( \
			+xmc_ext+.c \
			+libext+.v.sv \
			+systemverilog_ext+.sv \
			+vlog_ext+.v \
		)

		foreach def ( $DEFINE_LIST )
			set DEFINES = ( \
				+define+$def \
				$DEFINES \
			) 
		end
		foreach dir ( $INCDIR )
			set INCLUDE = ( \
				+incdir+$dir \
				$INCLUDE \
			)
		end
	breaksw

	case "xmverilog" :
		if ( $Waves =~ 1 ) then
			set WaveOpt = +define+CADENCE
		endif

		set SIM_OPT = ( \
			+64bit \
			$WaveOpt \
			+access+r \
			+notimingchecks \
			-ALLOWREDEFINITION \
		)
		set SRC_EXT = ( \
			+xmc_ext+.c \
			+libext+.v.sv \
			+systemverilog_ext+.sv \
			+vlog_ext+.v \
		)

		foreach def ( $DEFINE_LIST )
			set DEFINES = ( \
				+define+$def \
				$DEFINES \
			) 
		end
		foreach dir ( $INCDIR )
			set INCLUDE = ( \
				+incdir+$dir \
				$INCLUDE \
			)
		end
	breaksw

	case "vcs" :
		if ( $Waves =~ 1 ) then
			set WaveOpt = +define+SYNOPSYS
		endif

		set SIM_OPT = ( \
			-o ${TOP_MODULE}.sim \
			-full64 \
			$WaveOpt \
			+incdir+.include \
			-debug_access+r \
			+notimingchecks \
			-ALLOWREDEFINITION \
		)
		set SRC_EXT = ( \
			+xmc_ext+.c \
			+libext+.v.sv \
			+systemverilogext+.sv \
			+verilog2001ext+.v \
		)

		foreach def ( $DEFINE_LIST )
			set DEFINES = ( \
				+define+$def \
				$DEFINES \
			) 
		end
		foreach dir ( $INCDIR )
			set INCLUDE = ( \
				+incdir+$dir \
				$INCLUDE \
			)
		end
	breaksw

	case "verilator" :
		if ( $Waves =~ 1 ) then
			set WaveOpt = +define+VCD
		endif

		set SIM_OPT = ( \
			-lint-only \
			$WaveOpt \
			+notimingchecks \
		)

		set SRC_EXT = ( \
			+libext+.v.sv \
			+systemverilogext+.sv \
		)

		set DEFINE_LIST = ( \
		)

		foreach def ( $DEFINE_LIST )
			set DEFINES = ( \
				+define+$def \
				$DEFINES \
			) 
		end
		foreach dir ( $INCDIR )
			set INCLUDE = ( \
				+incdir+$dir \
				$INCLUDE \
			)
		end
	breaksw

	case "xilinx_sim" :
		if ( $Waves =~ 1 ) then
			set WaveOpt = (-d VCD)
		endif

		set SIM_OPT = ( \
			$WaveOpt \
		)

		foreach def ( $DEFINE_LIST )
			set DEFINES = ( \
				--define $def \
				$DEFINES \
			)
		end

		foreach dir ( $INCDIR )
			set INCLUDE = ( \
				--include $dir \
				$INCLUDE \
			)
		end
	breaksw

	default :
		echo "Simulation Tool is not selected"
		exit 1
	breaksw
endsw



##############################
#       run simulation       #
##############################
if ( ${SIM_TOOL} =~ "xilinx_sim" ) then
	xvlog \
		--sv \
		${SIM_OPT} \
		${INCLUDE} \
		${DEFINES} \
		${TEST_FILE} \
		${RTL_FILE}

	xelab ${TOP_MODULE}_test
	xsim --R ${TOP_MODULE}_test
else
	${SIM_TOOL} \
		${SIM_OPT} \
		${SRC_EXT} \
		${INCLUDE} \
		${DEFINES} \
		${TEST_FILE} \
		${RTL_FILE}
endif
