#!/bin/sh
echo "Remove tool waves and logs? (y/n)"
read str
if [ $str == "y" ]; then
	rm -rf waves.shm
	rm -rf xcelium.d
	rm -rf .simvision
	rm -rf .bpad
	rm -rf csrc
	rm -rf *.daidir
	rm -rf verdiLog
	rm -f xmverilog.*
	rm -f simvision*.diag
	rm -f bpad*.err
	rm -f ucli.key
	rm -f sim_exe
	rm -f wave.fsdb
	rm -f novas*
fi
