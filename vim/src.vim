let g:srcdir = ''
let g:srcdir = g:srcdir . ' -y /home/gizaneko/proj/ParamMod/./rtl'
let g:srcdir = g:srcdir . ' -y /home/gizaneko/proj/ParamMod/./test'

" append compiler option
if !exists('g:syntastic_verilog_compiler_options')
	let g:syntastic_verilog_compiler_options = '-Wall '
endif
let g:syntastic_verilog_compiler_options = 
	\g:syntastic_verilog_compiler_options . g:srcdir

if !exists('g:syntastic_systemverilog_compiler_options')
	let g:syntastic_systemverilog_compiler_options = '-sv -Wall '
endif
let g:syntastic_systemverilog_compiler_options = 
	\g:syntastic_systemverilog_compiler_options . g:srcdir
