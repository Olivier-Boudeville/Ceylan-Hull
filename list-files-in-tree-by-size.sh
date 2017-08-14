#!/bin/sh

target_dir="$1"

if [ -z "${target_dir}" ] ; then
	target_dir="."
	echo "Will list all files, starting from current directory, sorted by decreasing size:"

else
	if [ ! -d "${target_dir}" ] ; then
		echo "  Error, target specified directory '${target_dir}' not found." 1>&2
		exit 5

	else

		echo "Will list all files, starting from directory '${target_dir}', sorted by decreasing size:"

		cd "${target_dir}"

	fi
fi

echo

/bin/find . -type f -exec /bin/du -h '{}' ';' | /bin/sort -hr | /bin/more
