set MAX_CORE	4

# search path settings
set search_path [concat \
	. \
	../rtl \
	../include \
]


set PROCESS "ASAP7"
#set PROCESS "SKY130"

# toolchain setting
set synopsys_tools [info exist synopsys_program_name]

if { $PROCESS == "ASAP7" } {
	# ASAP7 PDK
	#	url: 
	#		http://asap.asu.edu/asap/
	#	publication:
	#		L.T. Clark, V. Vashishtha, L. Shifren, A. Gujja, S. Sinha, 
	#		B. Cline, C. Ramamurthya, and G. Yeric, 
	#		“ASAP7: A 7-nm FinFET Predictive Process Design Kit,” 
	#		Microelectronics Journal, vol. 53, pp. 105-115, July 2016
	set search_path [concat \
	   $search_path \
	]

	# not memory macro is allowed
	set target_library [list]

	set CELLLIB "./ASAP7_PDKandLIB_v1p6/lib_release_191006"
	set CELLDIR "${CELLLIB}/asap7_7p5t_library/rev25"

	set CELLDIR "${CELLLIB}/asap7_7p5t_library/rev25/LIB/NLDM"

	# use only typical corner
	set target_cell [list \
		${CELLDIR}/asap7sc7p5t_SIMPLE_SRAM_TT_08302018 \
		${CELLDIR}/asap7sc7p5t_SIMPLE_SLVT_TT_08302018 \
		${CELLDIR}/asap7sc7p5t_SIMPLE_RVT_TT_08302018 \
		${CELLDIR}/asap7sc7p5t_SIMPLE_LVT_TT_08302018 \
		${CELLDIR}/asap7sc7p5t_SEQ_SRAM_TT_08302018 \
		${CELLDIR}/asap7sc7p5t_SEQ_SLVT_TT_08302018 \
		${CELLDIR}/asap7sc7p5t_SEQ_RVT_TT_08302018 \
		${CELLDIR}/asap7sc7p5t_SEQ_LVT_TT_08302018 \
		${CELLDIR}/asap7sc7p5t_OA_SRAM_TT_08302018 \
		${CELLDIR}/asap7sc7p5t_OA_SLVT_TT_08302018 \
		${CELLDIR}/asap7sc7p5t_OA_RVT_TT_08302018 \
		${CELLDIR}/asap7sc7p5t_OA_LVT_TT_08302018 \
		${CELLDIR}/asap7sc7p5t_INVBUF_SRAM_TT_08302018 \
		${CELLDIR}/asap7sc7p5t_INVBUF_SLVT_TT_08302018 \
		${CELLDIR}/asap7sc7p5t_INVBUF_RVT_TT_08302018 \
		${CELLDIR}/asap7sc7p5t_INVBUF_LVT_TT_08302018 \
		${CELLDIR}/asap7sc7p5t_AO_SRAM_TT_08302018 \
		${CELLDIR}/asap7sc7p5t_AO_SLVT_TT_08302018 \
		${CELLDIR}/asap7sc7p5t_AO_RVT_TT_08302018 \
		${CELLDIR}/asap7sc7p5t_AO_LVT_TT_08302018 \
	]
} elseif { $PROCESS == "SKY130" } {
	# SkyWater Open Source PDK
	#	github: https://github.com/google/skywater-pdk
	#	url : https://skywater-pdk.readthedocs.io/en/latest/
} else {
	echo "Select Some Process for Synthesis"
	exit
}


if { [info exist synopsys_program_name] } {
	##### Synopsys Tool chain (Design Compiler, Formality) #####
	# processor count
	set_host_option -max_cores ${MAX_CORE}

	# verification file setting
	set_svf ${RESULT_DIR}/${DESIGN}/${DESIGN}.mapped.svf

	# search path setting
	set search_path [concat \
		$search_path \
	]
	set_app_var search_path $search_path

	# add library extention
	set target_library [list]
	foreach lib_each $target_cell {
		lappend target_library  ${lib_each}.db
	}

	if { $synopsys_program_name == "dc_shell" } {
		# library for synthesis
		set DW_LIB ${synopsys_root}/libraries/syn/dw_foundation.sldb
		set_app_var synthetic_library ${DW_LIB}
		set_app_var link_library [concat $target_library $DW_LIB]

		# read verilog file
		if { [info exist FILE_LIST] } {
			analyze -format verilog ${FILE_LIST}
		}
		if { [info exist SV_FILE_LIST] } {
			analyze -format sverilog ${SV_FILE_LIST}
		}
		elaborate ${DESIGN}

		# dont touch constraints
		if { [info exist DONT_TOUCH_CELL] } {
			foreach cell ${DONT_TOUCH_CELL} {
				set_dont_touch [get_cells -hierarchical $cell]
			}
		}
		#set_dont_touch ${DONT_TOUCH_CELLS}

		# synthesis option and compile
		source -echo -verbose ${TCL_DIR}/clk_const.tcl
		check_design > ${REPORT_DIR}/${DESIGN}/check_design.rpt
		compile_ultra

		# reports
		report_area -nosplit > ${REPORT_DIR}/${DESIGN}/report_area.rpt
		report_power -nosplit > ${REPORT_DIR}/${DESIGN}/report_power.rpt
		report_timing -nosplit > ${REPORT_DIR}/${DESIGN}/report_timing.rpt

		# output result
		write -hierarchy -format ddc -output ${RESULT_DIR}/${DESIGN}/${DESIGN}.ddc
		write -hierarchy -format verilog -output ${RESULT_DIR}/${DESIGN}/${DESIGN}.mapped.v
	} elseif { $synopsys_program_name == "fm_shell" } {
		# library for formal verification
		#set_app_var hdlin_dwroot /cad/synopsys/syn/O-2018.06-SP3
		set dc_shell_path [exec which dc_shell | cut -d "/" -f 1-5]
		set_app_var hdlin_dwroot $dc_shell_path
		read_db -technology_library ${target_library}

		# load reference
		if { [info exist FILE_LIST] } {
			read_verilog -r ${FILE_LIST} -work_library WORK
		}
		if { [info exist SV_FILE_LIST] } {
			read_sverilog -r ${SV_FILE_LIST} -work_library WORK
		}
		set_top r:/WORK/${DESIGN}

		# load implementation
		read_ddc -i ${RESULT_DIR}/${DESIGN}/${DESIGN}.ddc
		set_top i:/WORK/${DESIGN}

		# matching reference and implementation
		match

		# output result
		if { ![verify] } {  
			report_unmatched_points > ${REPORT_DIR}/${DESIGN}/fmv_unmatched_points.rpt
			report_failing_points > ${REPORT_DIR}/${DESIGN}/fmv_failing_points.rpt
			report_aborted > ${REPORT_DIR}/${DESIGN}fmv_aborted_points.rpt
			analyze_points -failing > ${REPORT_DIR}/${DESIGN}/fmv_failing_analysis.rpt
			report_svf_operation [find_svf_operation -status rejected]
		}
	}
} else {
	##### Cadence Tool chain (GENUS) #####

	# target design
	set design ${DESIGN}

	# add library extention
	set target_library [list]
	foreach lib_each $target_cell {
		lappend target_library  ${lib_each}.lib
	}

	# path/library settings
	set_db / .lib_search_path [concat .]
	set_db / .library $target_library

	# read hdl
	set_db / .hdl_search_path $search_path
	if { [info exist FILE_LIST] } {
		read_hdl ${FILE_LIST}
	}
	if { [info exist SV_FILE_LIST] } {
		read_hdl -sv ${SV_FILE_LIST}
	}
	elaborate

	# set top design
	#set design ${DESIGN}
	current_design ${DESIGN}

	# dont touch constraints
	if { [info exist DONT_TOUCH_CELL] } {
		foreach cell ${DONT_TOUCH_CELL} {
			set_dont_touch [get_cells -hierarchical $cell]
		}
	}
	#set_dont_touch ${DONT_TOUCH_CELLS}

	# synthesis option and compile
	source -echo -verbose ${TCL_DIR}/clk_const.tcl
	check_design > ${REPORT_DIR}/${DESIGN}/check_design.rpt

	# synthesis
	syn_generic
	syn_map
	syn_opt

	# output result
	write_hdl -generic ${DESIGN} > ${RESULT_DIR}/${DESIGN}/${DESIGN}.generic_gate.v
	write_hdl -lec ${DESIGN} > ${RESULT_DIR}/${DESIGN}/${DESIGN}.mapped.v

	# report
	report_area > ${REPORT_DIR}/${DESIGN}/report_area.rpt
	report_power > ${REPORT_DIR}/${DESIGN}/report_power.rpt
	report_timing > ${REPORT_DIR}/${DESIGN}/report_timing.rpt
	report timing -lint > ${REPORT_DIR}/${DESIGN}/report_timing_lint.rpt
}
