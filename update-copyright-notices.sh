#!/bin/sh

do_debug=1

#new_year=`date '+%Y'`

USAGE="
Usage: "`basename $0`" CODE_TYPE ROOT_DIRECTORY PREVIOUS_NOTICE NEWER_NOTICE
Updates the copyright notices of code of specified type found from specified root directory.

CODE_TYPE is among:
  - 'C++', for *.h, *.h.in, *.cc, *.cpp files
  - 'Erlang', for *.hrl, *.erl files
Ex: "`basename $0`" Erlang $HOME/My-program-tree \"2008-2010 Foobar Ltd\" \"2008-2011  Foobar Ltd\"
This will replace '% Copyright (C) 2008-2010 Foobar Ltd' by '% Copyright (C) 2008-2011 Foobar Ltd' in all Erlang files (*.hrl and *.erl) found from $HOME/My-program-tree.
"



if [ ! $# -eq 4 ] ; then

		echo "  Error, exactly four parameters are required.
$USAGE" 1>&2
		exit 5

fi


code_type=$1

case $code_type in

	Erlang)
		code_type=1
		;;

	C++)
		code_type=2
		;;

   *)
		echo "  Error, unknown code type ($code_type).
$USAGE" 1>&2
		exit 10
		;;

esac



root_dir=$2

if [ -z "$root_dir" ] ; then

		echo "  Error, no root directory specified.
$USAGE" 1>&2
		exit 10

fi


if [ ! -d "$root_dir" ] ; then

		echo "  Error, specified root directory ($root_dir) does not exist.
$USAGE" 1>&2
		exit 15

fi

old_notice="$3"
new_notice="$4"


cd $root_dir


replace_name="replace-in-file.sh"

base_dir=`dirname $0`
replace_script=`PATH=$base_dir:$PATH which $replace_name`
#echo "replace_script = $replace_script"

if [ ! -x "$replace_script" ] ; then

	echo "  Error, no executable replacement script ($replace_name) found." 1>&2
	exit 3

fi



if [ $code_type -eq 1 ] ; then

	# Erlang:

	# -L: follow symlinks.
	target_files=`find -L . -name '*.hrl' -o -name '*.erl'`

	target_pattern="^% Copyright (C) $old_notice"
	replacement_pattern="% Copyright (C) $new_notice"

elif [ $code_type -eq 2 ] ; then

	# C++:
	target_files=`find -L . -name '*.h' -o -name '*.h.in' -o -name '*.cc' -o -name '*.cpp'`
	target_pattern="^ \* Copyright (C) $old_notice"
	replacement_pattern=" * Copyright (C) $new_notice"

fi


if [ $do_debug -eq 0 ] ; then

	echo "code type = $code_type"
	echo "root dir = $root_dir"
	echo "old_notice = $old_notice"
	echo "new_notice = $new_notice"
	echo "target_pattern = $target_pattern"
	echo "replacement_pattern = $replacement_pattern"
	echo "target_files = $target_files"

fi


target_count=`echo $target_files | wc -w`

if [ $target_count -eq 0 ] ; then

	echo "  No target file found."
	exit 0

fi

echo "  $target_count files will be inspected now..."

count=0

for f in $target_files ; do

	if grep -e "$target_pattern" $f 1>/dev/null 2>&1 ; then

		#echo "  + found in $f"
		$replace_script "$old_notice" "$new_notice" $f
		count=`expr $count + 1`

	else

		res=`cat $f | grep -i 'copyright ' 2>&1`
		#echo "res = $res"

		if [ -z "$res" ] ; then

			echo "  + no copyright notice at all found in $f"

		else

			# Do not display changes already performed:
			if [ ! "$res" = "$replacement_pattern" ] ; then

				echo "  + previous copyright notice not found in $f, best candidates:
$res"
			fi

		fi

	fi

done


echo "  $count copyright notice(s) updated."
