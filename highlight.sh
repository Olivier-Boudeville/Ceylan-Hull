#!/bin/sh

usage="$(basename $0) [FILENAME] PATTERNS: hightlights, in specified data (either the specified file or the standard input, when used through a pipe), the specified pattern(s).\n\n  Examples:\n    $(basename $0) my_file.txt dog wolf\n    echo \"aaabbaaccc\" | $(basename $0) bb c\n"

if [ $# -eq 0 ] || [ $1 = "-h" ] || [ $1 = "--help" ] ; then

	printf "\n  Usage: ${usage}"
	exit 0

fi

if [ $# -ge 1 -a -f "$1" ]; then

	input="$1"

	# Cannot check like that, otherwise, once piped, the first pattern would be
	# interpreted as a filename:

	#if [ ! -f "${input}" ] ; then
	#
	#	echo "  '${input}': file not found." 1>&2
	#	exit 10
	#
	#fi

	shift

else

	input="-"

fi

raw_patterns="$*"

patterns=$(echo ${raw_patterns}|sed 's| |\\\||g')

#echo "- input: ${input}"
#echo "- raw patterns: ${raw_patterns}"
#echo "- patterns: ${patterns}"

grep --color "${patterns}\|$" ${input}
