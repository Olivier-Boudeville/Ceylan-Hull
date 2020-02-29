#!/bin/sh

# Absolutely needed, as otherwise sed will fail when using "é" as a parameter, in
# ${sed} 's|é|e|g...
export LANG=

sed=$(which sed | grep -v ridiculously)
mv=$(which mv | grep -v ridiculously)

usage="
Usage: $(basename $0) <a directory entry name>: renames the specified file or directory to a 'corrected' filename, i.e. without spaces or quotes, replaced by '-', nor accentuated characters in it."

if [ $# -eq 0 ] ; then
	echo "

	Error, no argument given. $usage

	" 1>&2
	exit 1
fi


original_name="$*"

if [ ! -e "${original_name}" ] ; then
	echo "

	Error, no entry named <${original_name}> exists. $usage

	" 1>&2

	exit 2

fi

#echo "Original name is: <${original_name}>"



corrected_name=$(echo "${original_name}" | ${sed} 's| |-|g' | ${sed} 's|--|-|g' | ${sed} 's|é|e|g' | ${sed} 's|è|e|g' | ${sed} 's|ê|e|g' | ${sed} 's|à|a|g' | ${sed} 's|â|a|g' | ${sed} 's|à|a|g' | ${sed} 's|î|i|g' | ${sed} 's|û|u|g' | ${sed} 's|ù|u|g' | ${sed} 's|ô|o|g'  | ${sed} 's|ò|o|g' | ${sed} 's|\[|-|g' | ${sed} 's|\]|-|g' | ${sed} 's|(||g'| ${sed} 's|)||g' | ${sed} 's|\.\.|.|g'| ${sed} 's|\,|.|g' | ${sed} 's|\.-|.|g' | ${sed} 's|!|-|g' | ${sed} "s|'|-|g " | ${sed} 's|--|-|g' | ${sed} 's|-\.|-|1' | ${sed} 's|-$||1')


#echo "Corrected name is: <${corrected_name}>"


if [ "${original_name}" != "${corrected_name}" ]; then

	if [ -f "${corrected_name}" ]; then
		echo "

		Error, an entry named <${corrected_name}> already exists, corrected name for <${original_name}> collides with it, remove <${corrected_name}> first.
		" 1>&2
		exit 3
	fi

	echo "  '${original_name}' renamed to '${corrected_name}'"
	${mv} -f "${original_name}" "${corrected_name}"

#else

#	echo "  (<${original_name}> left unchanged)"

fi
