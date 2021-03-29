# name settings
set REPORT_DIR	report
set RESULT_DIR	result
set TCL_DIR		tcl

set DESIGN		sel_minmax
#set FILE_LIST	[concat \
#]
set SV_FILE_LIST [concat \
	${DESIGN}.sv \
	bin_dec.sv \
]

set DESIGN_NO_CLK	1

source -echo -verbose $TCL_DIR/common.tcl

quit
