#!/bin/sh

usage="Usage: $(basename $0) [TARGET_DIR]: lists all local, direct directories of any specified directory, or from the current one. Useful for overcrowded base directories."

#target_dir="$(pwd)"
target_dir="."

if [ -n "$1" ]; then

	target_dir="$1"
	shift

fi

if [ ! $# -eq 0 ]; then

	echo "  Error, extra parameters specified.
${usage}" 1>&2

	exit 5

fi

echo "The local directories in '${target_dir}' are:"

# Min to avoid '.':
find ${target_dir} -mindepth 1 -maxdepth 1 -type d
