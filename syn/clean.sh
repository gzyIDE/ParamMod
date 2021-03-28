#!/bin/sh

# remove tool generated files and directories
echo "Remove tool generated files? (y/n)"
read str
if [ $str == "y" ]; then
	rm -rf	alib-52
	rm -rf	formality*_svf
	rm -rf	FM_WORK*
	rm -rf	*.mr
	rm -rf	*.syn
	rm -rf	*.pvl
	rm -rf	fv
	rm -f	*.log
	rm -f	*.lck
	rm -f	genus.cmd*
	rm -f	genus.log*
fi

# clean log and reports
echo "Remove synthesis and formality result? (y/n)"
read str
if [ $str == "y" ]; then
	rm -rf	log
	rm -rf	report
	rm -rf	result
fi
