#!/bin/sh

all_opt="--all"

usage="Usage: $(basename $0) [-h|--help] [${all_opt}] [FILES]: compares the current (committed) version of specified file(s) (actually: pathspecs) with their previous one (each) or, if the '${all_opt}' option is specified, with all their previous versions, back to the very first ones that were committed."

#svn diff -r PREV:BASE $* | more


if [ "$1" = "-h" ] || [ "$1" = "-h" ]; then
	echo "${usage}"
	exit 0
fi


all=1

if [ "$1" = "${all_opt}" ]; then
	all=0
	shift
fi


# Now false:
#if [ $# -eq 0 ]; then
#
#	echo "  Error, at least one file shall be specified.
#${usage}" 1>&2
#
#	exit 5
#
#fi


log_opts="-p -m"

if [ $# -eq 1 ]; then

	# Added to see changes that occurred prior to a rename (requires exactly one
	# pathspec):
	#
	log_opts="${log_opts} --follow"

fi

# See https://stackoverflow.com/questions/10176601/git-diff-file-against-its-last-change/:
if [ $all -eq 0 ]; then

	echo "  Displaying all previous committed versions for '$*':"
	git log ${log_opts} $*

else

	echo "  Displaying the previous committed version for '$*':"
	git log ${log_opts} -n 1 $*

fi
