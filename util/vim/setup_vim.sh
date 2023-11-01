#!/bin/tcsh

##### Parser tool
#set lint_tool = verilator
set lint_tool = slang


##### Parameters
### Vim setup directory
#		It is created under each source file directory
set vim_setup_dir = .vim-verilog

### template files
set include_setup = inc.vim
set include_option = ${lint_tool}/inc_opt.vim
set src_setup = src.vim
set src_option = ${lint_tool}/src_opt.vim
set src_template = ${lint_tool}/src_template.vim

### configuration options
#	include : include file configuration (inc.vim)
#	source  : source file configuration (src.vim)
#	design  : configuration for each design (${module_name}.vim)
set setup_include = 1
set setup_source = 1
set setup_design = 1
set allow_setup_design_overwrite = 0

### directories to be skipped
set skip_word = (\
	bkp \
	gomi \
	template \
	sv2v \
)

### verilog source file extension (default v, sv)
#	extention without "."
set verilog_src_ext = (\
)

### verilog header file extension (default vh, svh)
#	extention without "."
set verilog_header_ext = ( \
)



##### run directory checking
set top = `git rev-parse --show-toplevel`
if ( $top =~ "" ) then
	# Not in git repository
	#	executed in ${top directory}/vim (= Where this script locates)
	set current_dir = `pwd`
	set current_dir = `basename $current_dir`
	if ( $current_dir != "vim" ) then
		echo "run setup_vim.sh in vim directory"
		exit 1
	endif
	cd ..
	set top = `pwd`
	set vimdir = ${top}/util/vim
else
	# In git repository
	cd $top
	set vimdir = ${top}/util/vim
endif



##### find command setup
### set find options for skipped list
set grep_skip = ""
foreach skip ($skip_word)
	#set find_skip = "$find_skip -not -path "'"*'"$skip"'*" '
	#set find_skip = "$find_skip -name "'"*'"$skip"'*" -prune '
	set grep_skip = "$grep_skip| grep -v $skip "
end



### set find options for source file search
set find_base = "find . "
#set find_src = "${find_base}${find_skip} -or "'-type f -name "*.v" -or -name "*.sv"'
set find_src = "${find_base} "'-type f -name "*.v" -or -name "*.sv"'
foreach ext ($verilog_src_ext)
	set find_src = "$find_src -or -name "'"*.'"$ext"'" '
end



### set find options for header search
#set find_header = "${find_base}${find_skip} -or "'-type f -name "*.vh" -or -name "*.svh"'
set find_header = "${find_base} "'-type f -name "*.vh" -or -name "*.svh"'
foreach ext ($verilog_header_ext)
	set find_header = "$find_header -or -name "'"*.'"$ext"'" '
end



### search for source and header files
echo "Creating include file list"
set inc_list = `eval "$find_header"`
set inc_files = ()
foreach inc_file ( $inc_list )
	set inc_files = ($inc_files `eval "echo $inc_file${grep_skip}"`)
end
set inc_dirs = `echo $inc_files | xargs dirname | sort | uniq`
echo "Include Directories"
echo "    $inc_dirs"

echo "Creating source file list"
set src_list = `eval "$find_src"`
set src_files = ()
foreach src_file ( $src_list )
	set src_files = ($src_files `eval "echo ${src_file}${grep_skip}"`)
end
set src_dirs = `echo $src_files | xargs dirname | sort | uniq`
echo "Source Directories"
echo "    $src_dirs"



##### create include/source file setup script
echo "Writing include directory setup scripts"
echo "let g:incdir = ''" >! ${vimdir}/${include_setup}
set inc_prefix = "let g:incdir = g:incdir . ' +incdir+"
foreach inc_dir ( $inc_dirs )
	mkdir -p ${top}/${inc_dir}/${vim_setup_dir}
	echo "${inc_prefix}${top}/${inc_dir}'" >> ${vimdir}/${include_setup}
end
cat ${vimdir}/${include_option} >> ${vimdir}/${include_setup}

echo "Writing source directory setup scripts"
echo "let g:srcdir = ''" >! ${vimdir}/${src_setup}
set src_prefix = "let g:srcdir = g:srcdir . ' -y "
foreach src_dir ( $src_dirs )
	mkdir -p ${top}/${src_dir}/${vim_setup_dir}
	echo "${src_prefix}${top}/${src_dir}'" >> ${vimdir}/${src_setup}
end
cat ${vimdir}/${src_option} >> ${vimdir}/${src_setup}



###### distribute include/source setup files
foreach dir_name ( $inc_dirs $src_dirs )
	\cp -f ${vimdir}/${include_setup} ${dir_name}/${vim_setup_dir}/${include_setup}
	\cp -f ${vimdir}/${src_setup} ${dir_name}/${vim_setup_dir}/${src_setup}
end



##### create setup file for independent source files
if ( $setup_design =~ 1 ) then
	foreach src_file ( $src_files $inc_files )
		set file_name = `basename -s .sv $src_file`
		set file_name = `basename -s .v $file_name`
		set file_name = `basename -s .svh $src_file`
		set file_name = `basename -s .vh $file_name`
		foreach ext ($verilog_src_ext $verilog_header_ext)
			set file_name = `basename -s .$ext $file_name`
		end
		set filepath = `dirname $src_file`
		set setpath = ${top}/${filepath}/${vim_setup_dir}
		set vim_file = ${setpath}/${file_name}.vim
		if ( ! -f $vim_file || $allow_setup_design_overwrite =~ 1 ) then
			cp -f ${vimdir}/${src_template} ${vim_file}
		endif
	end
endif
