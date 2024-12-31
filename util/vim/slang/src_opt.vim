
" append compiler option
if !exists('g:syntastic_verilog_compiler_options')
	let g:syntastic_verilog_compiler_options = '-Wunused -Wextra -Wconversion --allow-dup-initial-drivers'
endif
let g:syntastic_verilog_compiler_options = 
	\g:syntastic_verilog_compiler_options . g:srcdir

if !exists('g:syntastic_systemverilog_compiler_options')
	let g:syntastic_systemverilog_compiler_options = '-Wunused -Wextra -Wconversion --allow-toplevel-iface-ports --allow-dup-initial-drivers'
endif
let g:syntastic_systemverilog_compiler_options = 
	\g:syntastic_systemverilog_compiler_options . g:srcdir
