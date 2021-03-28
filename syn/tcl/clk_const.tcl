# parameter settings
set CLK_CYC			0.5
set IN_DELAY_RATIO	0.10
set OUT_DELAY_RATIO	0.30


########## clk constraints ##########
#set_max_delay ${CLK_CYC}
if { ![info exists DESIGN_NO_CLK] || $DESIGN_NO_CLK != 1 } {
	create_clock \
		[get_ports clk] \
		-name CPU_CLK \
		-period ${CLK_CYC} \
		-waveform [list 0.000 [expr $CLK_CYC/2.0]]
	
	set inputs [remove_from_collection [all_inputs] [get_ports "clk"]]
	set_input_delay [expr $IN_DELAY_RATIO * $CLK_CYC] -clock CPU_CLK $inputs
	
	set outputs [all_outputs]
	set_output_delay [expr $OUT_DELAY_RATIO * $CLK_CYC] -clock CPU_CLK $outputs
	
	set_ideal_network [get_ports clk]
	#set_dont_touch_network [get_ports clk]

	########## reset configuration ##########
	set_ideal_network [ get_ports reset_ ]
	#set_ideal_latency [expr CLK_CYC/2] [get_ports reset_]
	#set_ideal_transition 0.30 [get_ports reset_]
}

if {[info exists DESIGN_NO_CLK]} {
	if { $DESIGN_NO_CLK == 1} {
		set_max_delay $CLK_CYC -from [all_inputs] -to [all_outputs]
	}
}
