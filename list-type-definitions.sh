#!/bin/sh


USAGE="  Usage: $(basename $0) [A_DIR]\nLists all Erlang type definitions from specified directory (if any), otherwise from current one."

base_dir=$(pwd)

if [ $# -eq 1 ] ; then

	base_dir="$1"

	if [ ! -d "${base_dir}" ] ; then

		echo "  Error, specified base search directory (${base_dir}) does not exist." 1>&2
		exit 10

	fi

	shift

fi

if [ ! $# -eq 0 ] ; then

	echo -e "$USAGE" 1>&2
	exit 5

fi


echo "Listing all Erlang type definitions from ${base_dir}..."
echo

# DUMMY to force the display of the corresponding file:
cd ${base_dir} && /bin/find . -name '*.?rl' -exec /bin/grep -e "[[:space:]]\?-type[[:space:]]\+" '{}' DUMMY ';' 2>/dev/null
