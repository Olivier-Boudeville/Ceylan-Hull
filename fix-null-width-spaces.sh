#!/bin/sh

usage="Usage: $(basename $0) [-h|--help] TARGET_FILE_PATH: removes all invisible spaces in the specified text file, i.e. Unicode spaces that have a null width and are likely to become problems with many tools."

if [ "$1" = "-h" ] || [ "$1" = "--help" ]; then

	echo "${usage}"

	exit 0

fi

target_file="$1"

if [ -z "${target_file}" ]; then

	echo "  Error, no target file specified.
${usage}" 1>&2

	exit 5

fi

shift


if [ ! $# -eq 0 ]; then

	echo "  Error, extra parameters specified.
${usage}" 1>&2

	exit 6

fi


if [ ! -f "${target_file}" ]; then

	echo "  Error, target file '${target_file}' does not exist.
${usage}" 1>&2

	exit 10

fi

if ! sed -i "s/$(echo -ne '\u200b')//g" "${target_file}"; then

	echo "  Error, removal failed." 1>&2
	exit 15

else

	echo " (removal success)"

fi
