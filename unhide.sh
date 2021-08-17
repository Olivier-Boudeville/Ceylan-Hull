#!/bin/sh

hide_suffix="-hidden"

usage="Usage: $(basename $0) [-r] [FILE_ELEMENTS]: unhides specified files or directories (simply by removing the '${hide_suffix}' suffix from their name).
  If no element is specified, unhides all (hidden) elements found (directly) in the current directory.
  If the '-r' option (recursive lookup) is specified, unhides all (hidden) elements found from the current directory (recursively).

See also: the reciprocal script 'hide.sh'."


if [ "$1" = "-h" ] || [ "$1" = "--help" ]; then
	echo "${usage}"
	exit 0
fi

if [ "$1" = "-r" ]; then

	echo "(recursive option specified, operating from the current directory, '$(pwd)')"
	target_elems="$(find . -name "*${hide_suffix}")"

else

	if [ $# -eq 0 ]; then

		echo "(no argument specified, operating - only - in the current directory, '$(pwd)')"
		target_elems="$(/bin/ls *${hide_suffix} 2>/dev/null)"

	else

		target_elems="$@"

	fi

fi

#echo "Target elements: ${target_elems}"

for e in ${target_elems}; do

	#echo "Unhiding element '$e'"

	# Removes any trailing slash for directories:
	source_element=$(echo "$e" | sed 's|/$||1')

	if [ ! -e "${source_element}" ]; then

		echo "  Error, the element '${source_element}' does not exist.
${usage}" 1>&2
		exit 10

	fi

	target_element=$(echo "${source_element}" | sed "s|${hide_suffix}$||1")

	if [ -e "${target_element}" ]; then
		echo "  Error, the target element '${target_element}' (to be used to unhide the specified file) already exists." 1>&2
		exit 15

	fi

	/bin/mv "${source_element}" "${target_element}"

	echo " '${source_element}' has been unhidden, as: '${target_element}'."

done
