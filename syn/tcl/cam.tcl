# name settings
set REPORT_DIR	report
set RESULT_DIR	result
set TCL_DIR		tcl

set DESIGN		cam
#set FILE_LIST	[concat \
#]
set SV_FILE_LIST [concat \
	${DESIGN}.sv \
]

source -echo -verbose $TCL_DIR/common.tcl

quit
