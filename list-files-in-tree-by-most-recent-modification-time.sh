#!/bin/sh

usage="Usage: $(basename $0) [DIR]: lists, from any specified directory otherwise from the current one, all files in tree, sorted from the most recently modified to the last."

target_dir="$1"

if [ -z "${target_dir}" ]; then
	target_dir="."
	echo "Listing all files, starting from current directory, sorted from latest-modified ones to the oldest-modified ones:"

else
	if [ ! -d "${target_dir}" ]; then
		echo "  Error, target specified directory '${target_dir}' not found." 1>&2
		exit 5

	else

		echo "Listing all files, starting from directory '${target_dir}', sorted from latest-modified ones to the oldest-modified ones:"

		cd "${target_dir}"

	fi
fi

echo

# 'find" location varies quite a lot depending on the distros:
find -type f -printf "%TY-%Tm-%Td %TT %p\n" | sort -nr | more
