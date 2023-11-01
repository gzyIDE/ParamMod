"============================================================================
"File:        slang.vim
"Description: Syntax checking plugin for syntastic
"Maintainer:  Yosuke Ide <gizaneko at outlook dot jp>
"============================================================================

if exists('g:loaded_syntastic_systemverilog_slang_checker')
    finish
endif
let g:loaded_syntastic_systemverilog_slang_checker = 1

if !exists('g:syntastic_systemverilog_compiler_options')
    let g:syntastic_systemverilog_compiler_options = '-Wunused -Wextra -Wconversion'
endif

let s:save_cpo = &cpo
set cpo&vim

function! SyntaxCheckers_systemverilog_slang_IsAvailable() dict
    if !exists('g:syntastic_systemverilog_compiler')
        let g:syntastic_systemverilog_compiler = self.getExec()
    endif
    call self.log('g:syntastic_systemverilog_compiler =', g:syntastic_systemverilog_compiler)
    return executable(expand(g:syntastic_systemverilog_compiler, 1))
endfunction

function! SyntaxCheckers_systemverilog_slang_GetLocList() dict
    return syntastic#c#GetLocList('systemverilog', 'slang', {
        \ 'errorformat':
        \     '%f:%l:%c: %trror: %m,' .
        \     '%f:%l:%c: %tarning: %m',
        \ 'main_flags': '' })
endfunction

call g:SyntasticRegistry.CreateAndRegisterChecker({
    \ 'filetype': 'systemverilog',
    \ 'name': 'slang' })

let &cpo = s:save_cpo
unlet s:save_cpo

" vim: set sw=4 sts=4 et fdm=marker:
