#!/bin/sh

do_debug=1

new_year=$(date '+%Y')

usage="Usage: $(basename $0) [--quiet] CODE_TYPE ROOT_DIRECTORY PREVIOUS_NOTICE NEWER_NOTICE
Updates the copyright notices of the code of the specified type found from the specified root directory.

CODE_TYPE is among:
  - 'C++' (includes C), for *.h, *.h.in, *.cc, *.cpp, *.c files
  - 'Erlang', for *.hrl, *.erl files

For example $(basename $0) Erlang $HOME/My-program-tree \"2008-2010 Foobar Ltd\" \"2008-${new_year} Foobar Ltd\"
This will replace '% Copyright (C) 2008-2010 Foobar Ltd' with '% Copyright (C) 2008-${new_year} Foobar Ltd' in all Erlang files (*.hrl and *.erl) found from $HOME/My-program-tree.

Note that if PREVIOUS_NOTICE contains characters that are meaningful in terms of Regular Expressions, they must be appropriately escaped.

Example for ampersand (&): $(basename $0) Erlang $HOME/My-program-tree \"2008-2010 Foobar R\&D Ltd\" \"2008-${new_year} Foobar R\&D Ltd\"

See also update-all-copyright-notices.sh for more global (multi-year) updates.
"

if [ "$1" = "-h" ] || [ "$1" = "--help" ]; then

	echo "${usage}"

	exit 0

fi


be_quiet=1


if [ $# -eq 5 ]; then

	if [ "$1" = "--quiet" ]; then

		be_quiet=0
		shift

	else

		echo "  Error, unknown '$1' option.

${usage}" 1>&2
		exit 2

	fi

fi


if [ ! $# -eq 4 ]; then

		echo "  Error, exactly four parameters are required.

${usage}" 1>&2
		exit 5

fi


code_type="$1"

case "${code_type}" in

	Erlang)
		code_type=1
		;;

	C++)
		code_type=2
		;;

   *)
		echo "  Error, unknown code type (${code_type}).

${usage}" 1>&2
		exit 10
		;;

esac



root_dir="$2"

if [ -z "${root_dir}" ]; then

	echo "  Error, no root directory specified.

${usage}" 1>&2
	exit 15

fi


if [ ! -d "${root_dir}" ]; then

	echo "  Error, the specified root directory (${root_dir}) does not exist.

${usage}" 1>&2
	exit 20

fi

old_notice="$3"
new_notice="$4"


cd "${root_dir}"


replace_name="replace-in-file.sh"

base_dir="$(dirname $0)"
replace_script="$(PATH=${base_dir}:${PATH} which ${replace_name} 2>/dev/null)"
#echo "replace_script = ${replace_script}"

if [ ! -x "${replace_script}" ]; then

	echo "  Error, no executable replacement script ('${replace_name}') found." 1>&2
	exit 3

fi


if [ ${code_type} -eq 1 ]; then

	# Erlang:

	# -L: follow symlinks.
	target_files=$(find -L . -name '*.hrl' -o -name '*.erl')

	target_pattern="^% Copyright (C) ${old_notice}"
	replacement_pattern="% Copyright (C) ${new_notice}"

elif [ ${code_type} -eq 2 ]; then

	# C/C++:
	target_files=$(find -L . -name '*.h' -o -name '*.h.in' -o -name '*.cc' -o -name '*.cpp' -o -name '*.c')
	target_pattern="^ \* Copyright (C) ${old_notice}"
	replacement_pattern=" * Copyright (C) ${new_notice}"

fi


if [ $do_debug -eq 0 ]; then

	echo "code type = ${code_type}"
	echo "root dir = ${root_dir}"
	echo "old_notice = ${old_notice}"
	echo "new_notice = ${new_notice}"
	echo "target_pattern = ${target_pattern}"
	echo "replacement_pattern = ${replacement_pattern}"
	echo "target_files = ${target_files}"

fi


target_count="$(echo ${target_files} | wc -w)"

if [ ${target_count} -eq 0 ]; then

	echo "  No target file found."
	exit 0

fi

echo "  ${target_count} files will be inspected now..."

count=0

for f in ${target_files}; do

	#echo

	if /bin/grep -e "${target_pattern}" $f 1>/dev/null 2>&1; then

		#echo "  + found in $f"

		# Target pattern found, let's replace it:
		${replace_script} "${old_notice}" "${new_notice}" "$f"
		count=$(expr ${count} + 1)

	else

		# Not found, searching for similar entries:

		res="$(/bin/cat $f | grep -i 'copyright ' 2>&1)"

		#echo "res = '${res}'"
		#echo "target_pattern = '${target_pattern}'"

		if [ -z "${res}" ]; then

			[ $be_quiet -eq 1 ] && echo "  + no copyright notice at all found in $f"

		else

			# Do not insist too much on changes already performed:
			if grep -e "${replacement_pattern}" "$f" 1>/dev/null 2>&1; then

				echo "  (latest copyright notice found in $f)"

			else

				#echo "replacement_pattern = '${replacement_pattern}'"
				[ $be_quiet -eq 1 ] && echo "  + previous copyright notice not found in $f, best candidates:
$res"
			fi

		fi

	fi

done


echo "  ${count} copyright notice(s) updated."
