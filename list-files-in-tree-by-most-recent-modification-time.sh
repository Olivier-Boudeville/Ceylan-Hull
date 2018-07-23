#!/bin/sh

target_dir="$1"

if [ -z "${target_dir}" ] ; then
	target_dir="."
	echo "Will list all files, starting from current directory, sorted from latest-modified ones to the oldest-modified ones:"

else
	if [ ! -d "${target_dir}" ] ; then
		echo "  Error, target specified directory '${target_dir}' not found." 1>&2
		exit 5

	else

		echo "Will list all files, starting from directory '${target_dir}', sorted from latest-modified ones to the oldest-modified ones:"
		cd "${target_dir}"

	fi
fi

echo


find -type f -printf "%TY-%Tm-%Td %TT %p\n" | sort -nr
