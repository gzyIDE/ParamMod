# name settings
set REPORT_DIR	report
set RESULT_DIR	result
set TCL_DIR		tcl

set DESIGN		fifo
#set FILE_LIST	[concat \
#]
set SV_FILE_LIST [concat \
	${DESIGN}.sv \
	cnt_bits.sv \
]

source -echo -verbose $TCL_DIR/common.tcl

quit
