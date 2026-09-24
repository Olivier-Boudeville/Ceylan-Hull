#!/bin/sh

context_count=3

usage="Usage: $(basename $0) FILE_PATH LINE_NUMBER [CONTEXT_COUNT]: displays the specified line, together with a number (default: ${context_count}) of context lines before and after that line, of the specified file, each line being prefixed with its number. 

Example: $(basename $0) my_text.txt 140 2
"


if [ "$1" = "-h" ] || [ "$1" = "--help" ]; then

	echo "  ${usage}"
	exit

fi


grep="$(which grep 2>/dev/null)"
#echo "grep = ${grep}"


if [ ! -x "${grep}" ]; then
	echo "  Error, no executable grep found." 1>&2
	exit 5
fi


nl="$(which nl 2>/dev/null)"

if [ ! -x "${nl}" ]; then
	echo "  Error, no executable 'nl' found." 1>&2
	exit 6
fi



if [ $# -le 1 ]; then
	echo "  Error, too few parameters.
${usage}" 1>&2
	exit 1
fi


if [ $# -ge 4 ]; then
	echo "  Error, too many parameters ($*).
${usage}" 1>&2
	exit 2
fi


target_file="$1"

# Possibly symlink:
if [ ! -e "${target_file}" ]; then

	echo "  Error, the target file, '${target_file}', does not exist." 1>&2
	exit 10

fi


l_number="$2"


if [ -z "$3" ]; then
	#echo "(applying default context line count, ${context_count})"
	:
else
	context_count="$3"
	#echo "(applying user-specified context line count, ${context_count})"
fi


echo "Displaying from file '${target_file}' line ${l_number} (numbered, with ${context_count} lines of context):" 


"${nl}" -ba "${target_file}" | sed -n "$((${l_number}-${context_count})),$((${l_number}+${context_count}))p" | sed -E "/${l_number}/s/.*/\x1b[32m&\x1b[0m/"
