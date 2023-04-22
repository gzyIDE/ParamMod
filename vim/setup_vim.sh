#!/bin/tcsh

##### Parameters
### Vim setup directory
#		It is created under each source file directory
set vim_setup_dir = .vim-verilog

### template files
set include_setup = inc.vim
set include_option = inc_opt.vim
set src_setup = src.vim
set src_option = src_opt.vim
set src_template = src_template.vim

### configuration options
set setup_include = 1
set setup_source = 1

### directories to be skipped
set skip_word = (\
	bkp \
	gomi \
	template \
	sv2v \
)

### verilog source file extension (default v, sv)
set verilog_src_ext = (\
)

### verilog header file extension (default vh, svh)
set verilog_header_ext = ( \
)



##### run directory checking
# it must be ${top directory}/vim (= Where this script locates)
#set pwd = `pwd`
#set current_dir = `basename $pwd`
#if ( $current_dir != "vim" ) then
#	echo "run setup_vim.sh in vim directory"
#	exit 1
#endif
## cd to top directory
#cd ..
#set top = `pwd`
#set vimdir = ${top}/vim
set top = `git rev-parse --show-toplevel`
cd $top
set vimdir = ${top}/vim
echo $vimdir



##### find command setup
### set find options for skipped list
set find_skip = ""
foreach skip ($skip_word)
	set find_skip = "$find_skip -not -path "'"*'"$skip"'*" '
end

### set find options for source file search
set find_base = "find . "
set find_src = "$find_base"'-type f -name "*.v" -or -name "*.sv"'"$find_skip"
foreach ext ($verilog_src_ext)
	set find_src = "$find_src -or -name "'"*.'"$ext"'"'
end

### set find options for header search
set find_header = "$find_base"'-type f -name "*.vh" -or -name "*.svh"'"$find_skip"
foreach ext ($verilog_src_ext)
	set find_src = "$find_src -or -name "'".'"$ext"'"'
end



##### create include file list
echo "Creating include directory list..."
# search for header files
set inc_list = ()
echo "let g:incdir = ''" > ${vimdir}/${include_setup}
set inc_prefix = "let g:incdir = g:incdir . ' +incdir+"
foreach incdir (`eval "$find_header" | xargs dirname | sort | uniq`)
	set inc_list = ($inc_list "${top}/${incdir}")
	echo "${inc_prefix}${top}/${incdir}'" >> ${vimdir}/${include_setup}
end
cat ${vimdir}/${include_option} >> ${vimdir}/${include_setup}



##### create source directory list
echo "Creating source directory list..."
set src_list = ()
echo "let g:srcdir = ''" > ${vimdir}/${src_setup}
set src_prefix = "let g:srcdir = g:srcdir . ' -y "
foreach srcdir (`eval "$find_src" | xargs dirname | sort | uniq`)
	set src_list = ($src_list $srcdir)
	mkdir -p ${top}/${srcdir}/${vim_setup_dir}
	echo "${src_prefix}${top}/${srcdir}'" >> ${vimdir}/${src_setup}
end
cat ${vimdir}/${src_option} >> ${vimdir}/${src_setup}



##### copy vim files
echo "Creating include/source file options to each source directory"
foreach srcdir (`eval "$find_src -exec dirname {} \;" | sort | uniq`)
	if ( $setup_include =~ 1 ) then
		\cp -f ${vimdir}/${include_setup} ${top}/${srcdir}/${vim_setup_dir}
	else
		rm -f ${top}/${srcdir}/${vim_setup_dir}/${include_setup}
	endif

	if ( $setup_source =~ 1 ) then
		\cp -f ${vimdir}/${src_setup} ${top}/${srcdir}/${vim_setup_dir}
	else
		rm -f ${top}/${srcdir}/${vim_setup_dir}/${src_setup}
	endif
end



##### create setup file for each source files
echo "Copying template options for each source files"
foreach srcfile (`eval "$find_src"`)
	set filename = `basename -s .sv $srcfile`
	set filename = `basename -s .v $filename`
	foreach ext ($verilog_src_ext)
		set filename = `basename -s $.ext $filename`
	end
	set filepath = `dirname $srcfile`
	set setpath = ${top}/${filepath}/${vim_setup_dir}
	if ( ! -f ${setpath}/${filename}.vim ) then
		cp -f ${vimdir}/${src_template} ${setpath}/${filename}.vim
	endif
end
