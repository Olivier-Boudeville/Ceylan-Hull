#!/bin/sh

# See diff-tree.sh for a recursive comparison.

# Defaults:
be_verbose=1
be_quiet=1
auto_edit=1
ignore_vcs=1
called_as_recursive=1
shorter_messages=1


usage="Usage: $(basename $0) <first directory (main one)> <second directory (typically to be integrated into first one)> [--vcs] [ -v ] [ -s ] [ -q ] [ -a ] [ -h | --help ]: performs a (single-level, non-recursive) comparison of the content of the two specified directories.

Compares all files that are present both in first and second directories, and warns if they are not identical. Warns too if some files are in one directory but not in the other.

Options:
   --vcs: VCS (Version Control System) mode, where VCS information (currently: git ones) are ignored (only focusing on file content)
   -v: verbose mode, where identical files are notified too
   -s: short mode, in which shorter messages are output
   -q: quiet mode, where only actual differences are displayed, without specifying which directories are traversed
   -a: automatic diff editing; a merge tool is triggered whenever a difference is detected, and an editor (default: $EDITOR, otherwise nedit) is triggered to modify the corresponding file being in the first directory
   -h or --help: this help"


#echo "[Debug] Received arguments are: '$*'."


# Needed early to be able to shift:
if [ "$1" = "-h" ] || [ "$1" = "--help" ]; then
		echo "${usage}"
		exit
fi


first_dir="$1"
second_dir="$2"


default_tex="[00;37;40m"
prefix_iden="     "
prefix_diff="[00;30;43m---> "
#prefix_noex="[00;37;41m#### "

# Was: tkdiff
merge_tool=$(which meld | grep -v ridiculously 2>/dev/null)

if [ -x "$EDITOR" ]; then
	editor_tool=$EDITOR
else
	editor_tool=$(which nedit|grep -v ridiculously 2>/dev/null)
fi


if [ ! -d "${first_dir}" ]; then
	echo "  Error, first directory specified ('${first_dir}') does not exist.
${usage}" 1>&2
	exit 2
fi

if [ ! -d "${second_dir}" ]; then
	echo "  Error, second directory specified ('${second_dir}') does not exist.
${usage}" 1>&2
	exit 3
fi

shift
shift

while [ $# -gt 0 ]; do
	token_eaten=1

	if [ "$1" = "--vcs" ]; then
		ignore_vcs=0
		token_eaten=0
	fi

	if [ "$1" = "-v" ]; then
		be_verbose=0
		token_eaten=0
	fi

	if [ "$1" = "-s" ]; then
		shorter_messages=0
		token_eaten=0
	fi

	if [ "$1" = "-r" ]; then
		# Less repetitive outputs if called recursively:
		# (see diff-tree.sh)
		called_as_recursive=0
		token_eaten=0
	fi

	if [ "$1" = "-q" ]; then
		be_quiet=0
		token_eaten=0
	fi

	if [ "$1" = "-a" ]; then
		auto_edit=0
		token_eaten=0
	fi

	if [ "$1" = "-h" ] || [ "$1" = "--help" ]; then
		echo "${usage}"
		exit
		token_eaten=0
	fi

	if [ $token_eaten -eq 1 ]; then
		echo "  Error, unknown argument ($1)." 1>&2
		exit 4
	fi
	shift

done



if [ ${auto_edit} -eq 0 ]; then

	if [ ! -x "${merge_tool}" ]; then
		echo "  Error, no executable merge tool found (${merge_tool}), automatic diff editing disabled." 1>&2
		auto_edit=1
	fi

	if [ ! -x "${editor_tool}" ]; then
		echo "  Error, no executable editor found (${editor_tool}), automatic diff editing disabled." 1>&2
		auto_edit=1
	fi


fi


# To tell a new directory is scanned:

if [ ${be_verbose} -eq 0 ]; then

	# Preferably disabled, as otherwise inserts a blank line:
	echo ${default_tex}

fi


if [ ${be_quiet} -eq 1 ]; then
	echo "Comparing files in '${first_dir}' and '${second_dir}':"
	#echo
fi


for f in $(/bin/ls ${first_dir}); do

	if [ ${ignore_vcs} -eq 1 ] || [ $(basename $f) != ".git" ]; then

		if [ ! -e "${second_dir}/$f" ]; then

			if [ ${shorter_messages} -eq 0 ]; then
				echo "${default_tex}${prefix_noex}'$f' only in FIRST.${default_tex}"
			else
				echo "${default_tex}${prefix_noex}'$f' is only in first directory (${first_dir}), i.e. not in ${second_dir}.${default_tex}"

			fi

		else

			if [ ! -d "${first_dir}/$f" ]; then

				if diff "${first_dir}/$f" "${second_dir}/$f" 1>/dev/null 2>&1 ; then
					[ ${be_verbose} -eq 1 ] || echo "${prefix_iden}('$f' identical in the two directories)${default_tex}"
				else
					echo "${prefix_diff} '$f' differs!${default_tex}"
					if [ ${auto_edit} -eq 0 ]; then
						${merge_tool} "${first_dir}/$f" "${second_dir}/$f" &
						${editor_tool} "${first_dir}/$f"
					fi
				fi
			else
				if [ ! -d "${second_dir}/$f" ]; then
					echo "${prefix_diff} '$f' is a directory in '${first_dir}' and a file in '${second_dir}'!${default_tex}"
				fi
			fi

		fi

	fi

done


for f in $(/bin/ls ${second_dir}); do

	if [ ! -e "${first_dir}/$f" ]; then
		if [ ${shorter_messages} -eq 0 ]; then
			echo "${prefix_noex}'$f' only in SECOND.${default_tex}"
		else
			echo "${prefix_noex}'$f' is only in second directory ('${second_dir}'), i.e. not in '${first_dir}'.${default_tex}"
		fi
	else
		if [ -d "${second_dir}/$f" ]; then
			if [ ! -d "${first_dir}/$f" ]; then
				echo "${prefix_diff} '$f' is a file in '${first_dir}' and a directory in '${second_dir}'!${default_tex}"
			fi
		fi
	fi
done


if [ ${called_as_recursive} -eq 1 ]; then
	[ ${be_verbose} -eq 0 ] || echo "(use the -v option for more information)"
fi
