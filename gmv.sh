#!/bin/sh

usage="Usage: $(basename 0) [-h|--help] SOURCE_FILE TARGET_FILE: moves the specified source file to the specified target one, with Git if appropriate, otherwise with a simple mv."


if [ "$1" = "-h" ] || [ "$1" = "--help" ]; then

	echo "${usage}"

	exit

fi


if [ ! $# -eq 2 ]; then

	echo "  Error, exactly two arguments expected.
${usage}" 1>&2

	exit 1

fi


src_file="$1"

if [ -z "${src_file}" ]; then

	echo "  Error, no source file specified.
${usage}" 1>&2

	exit 5

fi

# To include symlinks as well:
if [ ! -e "${src_file}" ]; then

	echo "  Error, source file '${src_file}' not found.
${usage}" 1>&2

	exit 10

fi


target_file="$2"

if [ -z "${target_file}" ]; then

	echo "  Error, no target file specified.
${usage}" 1>&2

	exit 15

fi

if ! git mv "${src_file}" "${target_file}" 2>/dev/null; then

	echo "  (basic move of '${src_file}' to '${target_file}')"
	/bin/mv "${src_file}" "${target_file}"

else

	echo "  (Git move of '${src_file}' to '${target_file}')"

fi
