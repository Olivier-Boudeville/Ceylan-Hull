#!/bin/sh


USAGE="Usage: $(basename $0) A_FILE: hides specified file (simply by adding a .orig extension to its name)."

if [ ! $# -eq 1 ] ; then

    echo -e "  Error, one argument expected.\n${USAGE}" 1>&2
    exit 5

fi


source_file="$1"

if [ ! -f "${source_file}" ]; then

    echo -e "  Error, the file '${source_file}' does not exist.\n${USAGE}" 1>&2
    exit 10

fi

target_file="${source_file}.orig"

if [ -f "${target_file}" ]; then

    echo -e "  Error, the target file '${target_file}' (to be used to hide the original) already exists." 1>&2
    exit 15

fi

/bin/mv "${source_file}" "${target_file}"

echo "('${source_file}' hidden, as '${target_file}')"
