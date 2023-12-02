#!/bin/tcsh

switch ( $TOP_MODULE )
	case "pri_enc" :
		set TEST_FILE = ${TBDIR}/${TOP_MODULE}_test.sv
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

	case "cnt_bits" :
		set TEST_FILE = ${TBDIR}/${TOP_MODULE}_test.sv
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
		set TEST_FILE = ${TBDIR}/${TOP_MODULE}_test.sv
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
		set TEST_FILE = ${TBDIR}/${TOP_MODULE}_test.sv
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
		set TEST_FILE = ${TBDIR}/${TOP_MODULE}_test.sv
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
		set TEST_FILE = ${TBDIR}/${TOP_MODULE}_test.sv
		if ( $GATE =~ 1 ) then
			set RTL_FILE = ( \
				$RTL_FILE \
				${GATEDIR}/${TOP_MODULE}/${TOP_MODULE}.mapped.v \
			)
		else
			set RTL_FILE = ( \
				${RTLDIR}/${TOP_MODULE}.sv \
				${RTLDIR}/selector.sv \
        ${RTLDIR}/reduct.sv \
			)
		endif
	breaksw

	case "cam2" :
		set TEST_FILE = ${TBDIR}/${TOP_MODULE}_test.sv
		if ( $GATE =~ 1 ) then
			set RTL_FILE = ( \
				$RTL_FILE \
				${GATEDIR}/${TOP_MODULE}/${TOP_MODULE}.mapped.v \
			)
		else
			set RTL_FILE = ( \
				${RTLDIR}/${TOP_MODULE}.sv \
				${RTLDIR}/selector.sv \
        ${RTLDIR}/reduct.sv \
			)
		endif
	breaksw

	case "ring_buf" :
		set TEST_FILE = ${TBDIR}/${TOP_MODULE}_test.sv
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
		set TEST_FILE = ${TBDIR}/${TOP_MODULE}_test.sv
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
		set TEST_FILE = ${TBDIR}/${TOP_MODULE}_test.sv
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
		set TEST_FILE = ${TBDIR}/${TOP_MODULE}_test.sv
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
		set TEST_FILE = ${TBDIR}/${TOP_MODULE}_test.sv
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
		set TEST_FILE = ${TBDIR}/${TOP_MODULE}_test.sv
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
		set TEST_FILE = ${TBDIR}/${TOP_MODULE}_test.sv
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
		set TEST_FILE = ${TBDIR}/${TOP_MODULE}_test.sv
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
		set TEST_FILE = ${TBDIR}/${TOP_MODULE}_test.sv
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

	case "block_shift" :
		set TEST_FILE = ${TBDIR}/${TOP_MODULE}_test.sv
		if ( $GATE =~ 1 ) then
			set RTL_FILE = ( \
				$RTL_FILE \
				${GATEDIR}/${TOP_MODULE}/${TOP_MODULE}.mapped.v \
			)
		else
			set RTL_FILE = ( \
				${RTLDIR}/${TOP_MODULE}.sv \
				${RTLDIR}/shifter.sv \
			)
		endif
	breaksw

	case "ram" :
		set TEST_FILE = ${TBDIR}/${TOP_MODULE}_test.sv
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

	case "lsfr" :
		set TEST_FILE = ${TBDIR}/${TOP_MODULE}_test.sv
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

	case "gray_cnt" :
		set TEST_FILE = ${TBDIR}/${TOP_MODULE}_test.sv
		if ( $GATE =~ 1 ) then
			set RTL_FILE = ( \
				$RTL_FILE \
				${GATEDIR}/${TOP_MODULE}/${TOP_MODULE}.mapped.v \
			)
		else
			set RTL_FILE = ( \
				${RTLDIR}/${TOP_MODULE}.sv \
				${RTLDIR}/bin_gray.sv \
				${RTLDIR}/gray_bin.sv \
			)
		endif
	breaksw

	case "oneshot" :
		set TEST_FILE = ${TBDIR}/${TOP_MODULE}_test.sv
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

	case "rr_arbiter" :
		set TEST_FILE = ${TBDIR}/${TOP_MODULE}_test.sv
		if ( $GATE =~ 1 ) then
			set RTL_FILE = ( \
				$RTL_FILE \
				${GATEDIR}/${TOP_MODULE}/${TOP_MODULE}.mapped.v \
			)
		else
			set RTL_FILE = ( \
				${RTLDIR}/${TOP_MODULE}.sv \
				${RTLDIR}/shifter.sv \
			)
		endif
	breaksw

	default : 
		# Error
		echo "Invalid Module"
		exit 1
	breaksw
endsw

if ( $SV2V =~ 1 ) then
	pushd $SV2VDIR
	./clean.sh
	./convert.sh $TOP_MODULE
	popd

	# Test vector
	set TEST_FILE = "${SV2VTESTDIR}/${TOP_MODULE}_test.v"

	# DUT
	set new_path = ()
	foreach file ( $RTL_FILE )
		set vfilename = `basename $file:r.v`
		set new_path = ( \
			$new_path \
			${SV2VRTLDIR}/${vfilename} \
		)
	end
	set RTL_FILE = ( $new_path )
endif
