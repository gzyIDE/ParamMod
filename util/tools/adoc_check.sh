#!/bin/tcsh

if ( $# != 1 ) then
	echo "usage: ./adoc_check.sh file.adoc"
	exit
endif

set TOPDIR = `git rev-parse --show-toplevel`
set TOOLSDIR = $TOPDIR/tools
if ( $TOPDIR =~ "" ) then
	echo "Do not use adoc_check.sh outside of git repository"
	exit
endif

if ( ! -f $1 ) then
	echo 'Target asciidoc file "'$1'" not found...'
	exit
endif

# extract asciidoc descriptions from SystemVerilog commnets
set in_sv = $1
set out_adoc = $1:r.adoc
set html_file = $1:r.html
python3 $TOOLSDIR/adoc_strip.py -i $in_sv -o $out_adoc
asciidoc $out_adoc
firefox $html_file
