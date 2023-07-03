#!/bin/sh

usage="Usage: $(basename $0) [-i|--ignore-case] [FILENAME] PATTERNS: highlights, in the specified data (either the specified file or the standard input, when used through a pipe), the specified pattern(s), in a case-insensitive manner if requested.

Examples:
	$(basename $0) my_file.txt dog wolf
	echo \"aaaBBaaccc\" | $(basename $0) -i bb c

Note that such highlighting should preferably be done last in a series of pipes, as the color coding may interfere for example with the matching performed by any subsequent grep.
"

if [ $# -eq 0 ] || [ $1 = "-h" ] || [ $1 = "--help" ]; then

	echo "${usage}"
	exit

fi

case_opt=""


if [ $1 = "-i" ] || [ $1 = "--ignore-case" ]; then

	#echo "(ignoring case)"
	case_opt="--ignore-case"
	shift

fi


if [ $# -ge 1 -a -f "$1" ]; then

	# From file:
	input="$1"

	# Cannot check like that, otherwise, once piped, the first pattern would be
	# interpreted as a filename:

	#if [ ! -f "${input}" ]; then
	#
	#   echo "  '${input}': file not found." 1>&2
	#   exit 10
	#
	#fi

	shift

else

	# From stdin:
	input="-"

fi

raw_patterns="$*"

# Patterns are separated with pipes with sed:
patterns=$(echo ${raw_patterns} | sed 's| |\\\||g')

#echo "- input: ${input}"
#echo "- raw patterns: ${raw_patterns}"
#echo "- patterns: ${patterns}"

# 'always' allows to pipe with a color-enabled pager afterwards:
# (e.g. with 'less -r -X')
#
#echo grep ${case_opt} --color=always "${patterns}\|$" "${input}"
grep ${case_opt} --color=always "${patterns}\|$" "${input}"
