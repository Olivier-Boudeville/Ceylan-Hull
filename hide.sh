#!/bin/sh


USAGE="Usage: $(basename $0) A_FILE_OR_DIRECTORY: hides specified file or directory (simply by adding a .orig extension to its name)."

if [ ! $# -eq 1 ] ; then

	echo -e "  Error, one argument expected.\n${USAGE}" 1>&2
	exit 5

fi

# Removes any trailing slash for directories:
source_element=$(echo "$1" | sed 's|/$||1')

if [ ! -e "${source_element}" ]; then

	echo -e "  Error, the element '${source_element}' does not exist.\n${USAGE}" 1>&2
	exit 10

fi

target_element="${source_element}.orig"

if [ -e "${target_element}" ]; then

	echo -e "  Error, the target element '${target_element}' (to be used to hide the original) already exists." 1>&2
	exit 15

fi

/bin/mv "${source_element}" "${target_element}"

echo "('${source_element}' hidden, as '${target_element}')"
