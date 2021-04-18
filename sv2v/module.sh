#!/bin/tcsh

switch ( $TOP_MODULE )
	case "pri_enc" :
		set RTL_FILE = ( \
			${SVDIR}/${TOP_MODULE}.sv \
		)
	breaksw

	case "cnt_bits" :
		set RTL_FILE = ( \
			${SVDIR}/${TOP_MODULE}.sv \
		)
	breaksw

	case "bin_dec" :
		set RTL_FILE = ( \
			${SVDIR}/${TOP_MODULE}.sv \
		)
	breaksw

	case "fifo" :
		set RTL_FILE = ( \
			${SVDIR}/${TOP_MODULE}.sv \
			${SVDIR}/cnt_bits.sv \
		)
	breaksw

	case "selector" :
		set RTL_FILE = ( \
			${SVDIR}/${TOP_MODULE}.sv \
		)
	breaksw

	case "cam" :
		set RTL_FILE = ( \
			${SVDIR}/${TOP_MODULE}.sv \
		)
	breaksw

	case "cam2" :
		set RTL_FILE = ( \
			${SVDIR}/${TOP_MODULE}.sv \
			${SVDIR}/selector.sv \
		)
	breaksw

	case "ring_buf" :
		set RTL_FILE = ( \
			${SVDIR}/${TOP_MODULE}.sv \
			${SVDIR}/cnt_bits.sv \
		)
	breaksw

	case "shifter" :
		set RTL_FILE = ( \
			${SVDIR}/${TOP_MODULE}.sv \
			${SVDIR}/cnt_bits.sv \
		)
	breaksw

	case "regfile" :
		set RTL_FILE = ( \
			${SVDIR}/${TOP_MODULE}.sv \
		)
	breaksw

	case "freelist" :
		set RTL_FILE = ( \
			${SVDIR}/${TOP_MODULE}.sv \
			${SVDIR}/selector.sv \
			${SVDIR}/cnt_bits.sv \
		)
	breaksw

	case "sel_minmax" :
		set RTL_FILE = ( \
			${SVDIR}/${TOP_MODULE}.sv \
			${SVDIR}/bin_dec.sv \
		)
	breaksw

	case "stack" :
		set RTL_FILE = ( \
			${SVDIR}/${TOP_MODULE}.sv \
			${SVDIR}/cnt_bits.sv \
		)
	breaksw

	case "reduct" :
		set RTL_FILE = ( \
			${SVDIR}/${TOP_MODULE}.sv \
		)
	breaksw

	case "gather" :
		set RTL_FILE = ( \
			${SVDIR}/${TOP_MODULE}.sv \
			${SVDIR}/cnt_bits.sv \
			${SVDIR}/selector.sv \
		)
	breaksw

	case "scatter" :
		set RTL_FILE = ( \
			${SVDIR}/${TOP_MODULE}.sv \
			${SVDIR}/cnt_bits.sv \
			${SVDIR}/selector.sv \
		)
	breaksw

	case "block_shift" :
		set RTL_FILE = ( \
			${SVDIR}/${TOP_MODULE}.sv \
			${SVDIR}/shifter.sv \
		)
	breaksw

	default : 
		# Error
		echo "Invalid Module"
		exit 1
	breaksw
endsw
