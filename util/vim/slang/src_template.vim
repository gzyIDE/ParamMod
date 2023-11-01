" define (Manually added by programmer)
let g:defines = ''
"let g:defines = g:sv_defines . '+define+SAMPLE_DEFINE '
"let g:defines = g:sv_defines . '+define+SAMPLE_DEFINE_VALUE=10 '

" dependent modules (Additional files that cannot be resolved)
let g:modules = ''
"let g:modules = g:modules . 'sample_module '

" additional compiler options
let g:exopt = ''
"let g:exopt = g:exopt . '-sample_opt '


" append compiler option
if !exists('g:syntastic_verilog_compiler_options')
	let g:syntastic_verilog_compiler_options = '-Wunused -Wextra -Wconversion'
endif
let g:syntastic_verilog_compiler_options = 
	\g:syntastic_verilog_compiler_options . g:defines . g:modules . g:exopt

if !exists('g:syntastic_systemverilog_compiler_options')
	let g:syntastic_systemverilog_compiler_options = '-Wunused -Wextra -Wconversion'
endif
let g:syntastic_systemverilog_compiler_options = 
	\g:syntastic_systemverilog_compiler_options . g:defines . g:modules . g:exopt
