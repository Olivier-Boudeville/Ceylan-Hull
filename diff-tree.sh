#!/bin/sh

# Defaults:
be_verbose=1
be_quiet=1
auto_edit=1
ignore_vcs=1


# See diff-dir.sh for a direct, non-recursive comparison.

usage="Usage: $(basename $0) <first directory (main one)> <second directory (typically to be integrated into first one)> [--vcs] [ -v ] [ -s ] [ -q ] [ -a ] [ -h | --help ]: performs a recursive comparison of the two specified trees.

Compares all files that are present both in first and second trees, and warns if they are not identical. Warns too if some files are in one directory but not in the other.

Options:
   --vcs: VCS (Version Control System) mode, where VCS information (currently: git ones) are ignored (only focusing on file content)
   -v: verbose mode, where identical files are notified too
   -s: short mode, in which shorter messages are output
   -q: quiet mode, where only actual differences are displayed, without specifying which directories are traversed
   -a: automatic diff editing; a merge tool is triggered whenever a difference is detected, and an editor (default: $EDITOR, otherwise nedit) is triggered to modify the corresponding file being in the first tree
   -h or --help: this help"

default_tex="[00;37;40m"
#prefix_iden="     "
#prefix_diff="[00;30;43m---> "
#prefix_noex="[00;37;41m#### "

diff_dir=$(which diff-dir.sh|grep -v ridiculously 2>/dev/null)

if [ ! -x "${diff_dir}" ]; then
	echo "Error, no diff tool for directories found (${diff_dir}).
$usage" 1>&2
	exit 10
fi


find=$(which find | grep -v ridiculously 2>/dev/null)

# Needed early to be able to shift:
if [ "$1" = "-h" ] || [ "$1" = "--help" ]; then
		echo "$usage"
		exit
fi

first_dir="$1"
second_dir="$2"

if [ -z "${second_dir}" ]; then
	echo "Error, not enough arguments specified.
$usage" 1>&2
	exit 1
fi

shift
shift

# -r for recursive:
args_to_propagate="$* -r"

while [ $# -gt 0 ]; do

	token_eaten=1

	if [ "$1" = "--vcs" ]; then
		ignore_vcs=0
		args_to_propagate="${args_to_propagate} --vcs"
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

	if [ "$1" = "-q" ]; then
		be_quiet=0
		token_eaten=0
	fi

	if [ "$1" = "-a" ]; then
		auto_edit=0
		token_eaten=0
	fi

	if [ "$1" = "-h" ] || [ "$1" = "--help" ]; then
		echo "$usage"
		exit
	fi

	if [ $token_eaten -eq 1 ]; then
		echo "  Error, unknown argument ($1).
$usage" 1>&2
		exit 4
	fi
	shift
done


if [ -z "${first_dir}" ]; then
	echo "Error, not enough arguments specified.
$usage" 1>&2
	exit 5
fi

if [ ! -d "${first_dir}" ]; then
	echo "Error, first directory specified (${first_dir}) does not exist.
$usage" 1>&2
	exit 10
fi


if [ ! -d "${second_dir}" ]; then
	echo "Error, second directory specified (${second_dir}) does not exist.
$usage" 1>&2
	exit 15
fi



old_path=$(pwd)

cd "${first_dir}"

if [ ${ignore_vcs} -eq 0 ]; then
	#echo "(ignoring VCS information)"
	# Not '.git':
	exclude_vcs_opt="-name .git -prune -o"
fi

#echo "Find command from $(pwd): ${find} . ${exclude_vcs_opt} -type d -print"

dirs=$(${find} . ${exclude_vcs_opt} -type d -print)

cd ${old_path}

#echo "dirs = ${dirs}"


for d in ${dirs}; do

	#echo "DIR = $d, BASE = $(basename $d)"

	if [ ${ignore_vcs} -eq 0 ] || [ $(basename $d) != ".git" ]; then

		if [ ${be_quiet} -eq 1 ]; then
			echo "$(basename $0) examining ${first_dir}/$d and ${second_dir}/$d"
		fi

		if [ ! -d "${second_dir}/$d" ]; then
			if [ ${shorter_messages} -eq 0 ]; then
				echo "${prefix_noex}Directory $d only in FIRST.${default_tex}"
			else
				echo "${prefix_noex}Directory $d is only in '${first_dir}' (not in '${second_dir}').${default_tex}"
			fi
		else
			${diff_dir} "${first_dir}/$d" "${second_dir}/$d" ${args_to_propagate}
		fi

	else

		if [ ${be_verbose} -eq 0 ]; then
			echo "(directory '$d' skipped)"
		fi

	fi

done


# Only thing to check then: there could be directories in second path not in
# first path:

cd ${second_dir}
dirs=$( ${find} . -type d )
cd ${old_path}

for d in ${dirs}; do

	if [ ! -d "${first_dir}/$d" ]; then
			if [ ${shorter_messages} -eq 0 ]; then
				echo "${prefix_noex}Directory $d only in SECOND.${default_tex}"
			else
				echo "${prefix_noex}Directory $d is only in '${second_dir}' (not in '${first_dir}').${default_tex}"
			fi
	fi

done
