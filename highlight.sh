#!/bin/sh

usage="$(basename $0) [FILENAME] [-i|--ignore-case] PATTERNS: highlights, in specified data (either the specified file or the standard input, when used through a pipe), the specified pattern(s), in a case-insensitive manner if requested.\n\n  Examples:\n    $(basename $0) my_file.txt dog wolf\n    echo \"aaaBBaaccc\" | $(basename $0) -i bb c\n"

if [ $# -eq 0 ] || [ $1 = "-h" ] || [ $1 = "--help" ]; then

	printf "\n  Usage: ${usage}"
	exit 0

fi

case_opt=""

if [ $1 = "-i" ] || [ $1 = "--ignore-case" ]; then

	case_opt="$1"
	shift

fi

if [ $# -ge 1 -a -f "$1" ]; then

	# From file:
	input="$1"

	# Cannot check like that, otherwise, once piped, the first pattern would be
	# interpreted as a filename:

	#if [ ! -f "${input}" ]; then
	#
	#	echo "  '${input}': file not found." 1>&2
	#	exit 10
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
# (ex: with 'less -r -X')
#
grep ${case_opt} --color=always "${patterns}\|$" "${input}"
