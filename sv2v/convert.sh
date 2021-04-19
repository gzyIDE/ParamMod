#!/usr/bin/tcsh

###############################################################################
# Invoke SystevemVerilog to Verilog converter
#	using "sv2v (https://github.com/zachjs/sv2v)"
###############################################################################

##### File and Directory Settings #####
set TOPDIR = ".."
set SVDIR = "${TOPDIR}/rtl"
set SVTESTDIR = "${TOPDIR}/test"
set SV2VDIR = "${TOPDIR}/sv2v"
set VDIR = "${SV2VDIR}/rtl"
set VTESTDIR = "${SV2VDIR}/test"
set GATEDIR = "${TOPDIR}/syn/result"
set INCLUDE = ()
set DEFINES = ()
mkdir -p ${VDIR}
mkdir -p ${VTESTDIR}



##### Include Files
set INCDIR = ( \
	${TOPDIR}/include \
	${SVTESTDIR} \
)



##### Defines
# Warning: Defines are preprocessed during converting processes!
set DEFINE_LIST = ( \
	WAVE_DUMP \
	VCD \
)



##### Conversion target
source target.sh
if ( $# =~ 0 ) then
	set TOP_MODULE = $DEFAULT_DESIGN
else
	set TOP_MODULE = $1
endif
source module.sh



##### Convert
foreach def ( $DEFINE_LIST )
	set DEFINES = ( \
		-D $def \
		${DEFINES} \
	)
end

foreach inc ( $INCDIR )
	set INCLUDE = ( \
		-I $inc \
		${INCLUDE} \
	)
end



##### Test Vector Conversion
set testname = ${TOP_MODULE}_test
if ( -f $VTESTDIR/${testname}.v ) then
	echo "$VTESTDIR/${testname}.v alreay exists. Conversion is skipped."
else
		echo "Converting $SVTESTDIR/${testname}.sv to $VTESTDIR/${testname}.v"
	sv2v -w stdout $DEFINES $INCLUDE $SVTESTDIR/${testname}.sv > $VTESTDIR/${testname}.v
endif



##### RTL Deisgn Conversion
foreach file ($RTL_FILE)
	set vfilename = `basename $file:r.v`
	#sv2v -w adjacent $DEFINES $INCLUDE $files
	if ( -f $VDIR/$vfilename ) then
		echo "$VDIR/$vfilename alreay exists. Conversion is skipped."
	else
		echo "Converting $file to $VDIR/$vfilename"
		sv2v -w stdout $DEFINES $INCLUDE $file > $VDIR/$vfilename
	endif
end
