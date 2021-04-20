#!/bin/sh

usage="Usage: $(basename $0) [DIR]: lists, from any specified directory otherwise from the current one, all files in tree, sorted by decreasing size of their content."

target_dir="$1"

if [ -z "${target_dir}" ]; then
	target_dir="."
	echo "Listing all files, starting from current directory, sorted by decreasing size:"

else
	if [ ! -d "${target_dir}" ]; then
		echo "  Error, target specified directory '${target_dir}' not found." 1>&2
		exit 5

	else

		echo "Listing all files, starting from directory '${target_dir}', sorted by decreasing size:"

		cd "${target_dir}"

	fi
fi

echo

# 'find" location varies quite a lot depending on the distros:
find . -type f -exec du -h '{}' ';' | sort -hr | more
