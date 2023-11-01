#!/bin/tcsh

set top = `git rev-parse --show-toplevel`

rm -f ./inc.vim
rm -f ./src.vim

cd ${top}
find -name .vim-verilog | xargs -I {} rm -rf {}
