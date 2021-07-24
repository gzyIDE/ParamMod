#!/usr/bin/python3
import os
import sys
import re
import copy
from argparse import ArgumentParser

def parser():
    # parser information setup
    prog='adoc_strip'
    description = 'Strip asciidoc format comments in Verilog/SystemVerilog source files'
    usage = 'usage: python3 {} ' .format(__file__)
    usage += '[-o outfile] [-i infile]'
    parse = ArgumentParser(
                prog=prog,
                description=description, 
                usage=usage,
                add_help=True
                )

    # Input Filename
    parse.add_argument(
                '-i', 
                '--input',
                type=str,
                action='store',
                default='main.sv',
                help='Set input verilog/systemverilog file name (Default: main.sv)'
                )

    # Output Filename
    parse.add_argument(
                '-o', 
                '--output',
                type=str,
                action='store',
                default='main.adoc',
                help='Set output asciidoc file name (Default: main.adoc)'
                )
    return parse.parse_args()

def strip_adoc(in_file):
    data = open(in_file, 'r').readlines()

    # parse state machine
    parsing = 0
    start_symbol = '<asciidoc>'
    end_symbol = '</asciidoc>'
    str_list = []
    for line in data:
        stripped = re.findall(r'//\s?(.*)',line)

        # ignore non-comment lines
        if len(stripped) == 0:
            continue
        else :
            stripped = stripped[0]

        # statemachine
        if parsing == 0 :
            if stripped == start_symbol :
                parsing = 1
        elif parsing == 1 :
            if stripped == end_symbol :
                str_list.append('')
                parsing = 0
            else:
                str_list.append(copy.deepcopy(stripped))

    if ( parsing == 1 ) :
        print('In file ' + in_file)
        print('EOF is reached before detecting parse end symbol: ' + end_symbol)
        sys.exit()

    return str_list

if __name__ == '__main__' :
    options = parser()
    in_file = options.input
    out_file = options.output

    # asciidoc region
    adoc_string = strip_adoc(in_file)

    # output into file
    with open(out_file, 'w') as f:
        f.write("\n".join(adoc_string))
