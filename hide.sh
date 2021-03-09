#!/bin/sh

hide_suffix="-hidden"

usage="Usage: $(basename $0) FILE_ELEMENT [FILE_ELEMENTS]: hides specified files or directories (simply by adding a '${hide_suffix}' suffix to their name).
See also: the reciprocal script 'unhide.sh'."


if [ $# -eq 0 ]; then

	echo "  Error, at least one argument expected.
${usage}" 1>&2
	exit 5

fi


if [ "$1" = "-h" ] || [ "$1" = "--help" ]; then
	echo "${usage}"
	exit 0
fi


while [ -n "$1" ]; do

	# Removes any trailing slash for directories:
	source_element="$(echo "$1" | sed 's|/$||1')"

	if [ ! -e "${source_element}" ]; then

		echo "  Error, the element '${source_element}' does not exist.
${usage}" 1>&2
		exit 10

	fi

	target_element="${source_element}${hide_suffix}"

	if [ -e "${target_element}" ]; then

		echo -"  Error, the target element '${target_element}' (to be used to hide the original) already exists." 1>&2
		exit 15

	fi

	/bin/mv "${source_element}" "${target_element}"

	echo "'${source_element}' has been hidden, as: '${target_element}'."

	shift

done
