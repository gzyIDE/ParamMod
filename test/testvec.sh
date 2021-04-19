#!/bin/tcsh

##### File and Directory Settings #####
set TOPDIR = ".."
set RTLDIR = "${TOPDIR}/rtl"
set TESTDIR = "${TOPDIR}/test"
set GATEDIR = "${TOPDIR}/syn/result"
set SV2VDIR = "${TOPDIR}/sv2v"
set SV2VRTLDIR = "${SV2VDIR}/rtl"
set SV2VTESTDIR = "${SV2VDIR}/test"
set INCDIR = ( \
	${TOPDIR}/include \
	${TESTDIR} \
)
set INCLUDE = ()
set DEFINES = ()
set RTL_FILE = ()



##### load configs
source sim_tool.sh
source target.sh



##### Output Wave
set Waves = 1
set WaveOpt



##### Simulation after Systemverilog to verilog (SV2V) Conversion
set SV2V = 0
if ( $SIM_TOOL =~ "iverilog" ) then
	# iverilog only supports verilog formats
	set SV2V = 1
endif



##### Defines
if ( $Waves =~ 1 ) then
	set DEFINE_LIST = ( WAVE_DUMP )
else 
	set DEFINE_LIST = ()
endif

##### Gate Level Simulation
set GATE = 0
#set GATE = 1
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

		set LIB_FILE = ( \
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
		set LIB_FILE = ()
	breaksw
endsw

########################################
#     Simulation Target Selection      #
########################################
if ( $# =~ 0 ) then
	set TOP_MODULE = $DEFAULT_DESIGN
else
	set TOP_MODULE = $1
endif

source module.sh



########################################
#        Simulation Tool Setup         #
########################################
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

	case "iverilog" :
		if ( $Waves =~ 1 ) then
			set WaveOpt = (-D VCD)
		endif

		set SIM_OPT = ( \
			$WaveOpt \
			-o ${TOP_MODULE}.sim \
		)

		set SRC_EXT = ()

		foreach def ( $DEFINE_LIST )
			set DEFINES = ( \
				-D $def \
				$DEFINES \
			)
		end

		foreach dir ( $INCDIR )
			set INCLUDE = ( \
				-I $dir \
				$INCLUDE \
			)
		end
	breaksw

	case "xilinx_sim" :
		if ( $Waves =~ 1 ) then
			set WaveOpt = ( \
				--define VCD \
			)
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
		${LIB_FILE} \
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
		${LIB_FILE} \
		${RTL_FILE}
endif
