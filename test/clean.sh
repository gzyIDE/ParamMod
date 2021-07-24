#!/bin/tcsh

source sim_tool.sh

if ( $SIM_TOOL =~ "xmverilog" ) then
	# cadence 
	echo "Removing file xmverilog.log"
	rm -f xmverilog.log

	echo "Removing file xmverilog.key"
	rm -f xmverilog.key

	echo "Removing file xmverilog.history"
	rm -f xmverilog.history

	echo "Removing directory xcelium.d"
	rm -rf xcelium.d

	echo "Removing directory waves.shm"
	rm -rf waves.shm

	echo "Removing directory .simvision"
	rm -rf .simvision

	echo "Removing directory .bpad"
	rm -rf .bpad

	foreach diag ( simvision*.diag )
		echo "Removing file $diag"
		rm -f $diag
	end
else if ( $SIM_TOOL =~ "vcs" ) then
	# synopsys
	echo "Removing file ucli.key"
	rm -f ucli.key
	rm -f waves.fsdb
	rm -f novas_dump.log

	foreach simbin ( *.sim )
		echo "Removing file $simbin"
		rm -f $simbin
	end

	echo "Removing directory csrc"
	rm -rf ./csrc

	foreach simdir ( *.sim.daidir )
		echo "Removing directory $simdir"
		rm -rf $simdir
	end
else if ( $SIM_TOOL =~ "verilator" ) then
else if ( $SIM_TOOL =~ "iverilog" ) then
	foreach simbin ( *.sim )
		echo "Removing file $simbin"
		rm -f $simbin
	end

	rm -f waves.vcd
else if ( $SIM_TOOL =~ "xilinx_sim" ) then
	echo "Removing simulation logs and results"
	rm -f webtalk*.jou >& /dev/null
	rm -f webtalk*.log >& /dev/null
	rm -f xsim*.jou >& /dev/null
	rm -f xsim*.log >& /dev/null
	rm -f xelab.log
	rm -f xelab.pb
	rm -f xvlog.log
	rm -f xvlog.pb
	rm -f waves.vcd
	rm -rf .Xil
	rm -rf xsim.dir
	rm -f waves.vcd
	rm -f waves.wdb

	echo "Removing Vivado-related log files"
	rm -f vivado*.jou >& /dev/null
	rm -f vivado*.log >& /dev/null
	#rm -f *.wdb

	pushd xilinx > /dev/null
	foreach file ( `ls` )
		if ( -d $file ) then
			rm -rf $file
		endif
	end
	popd > /dev/null
endif
