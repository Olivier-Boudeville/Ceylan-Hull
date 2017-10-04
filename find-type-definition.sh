#!/bin/sh


USAGE="  Usage: $(basename $0) A_TYPE [A_DIR]\nAttempts to find the definition of the specified Erlang type from specified directory (if any), otherwise from current one."

base_dir=$(pwd)

type="$1"

if [ $# -eq 2 ] ; then

	base_dir="$2"

	if [ ! -d "${base_dir}" ] ; then

		echo "  Error, specified base search directory (${base_dir}) does not exist." 1>&2
		exit 10

	fi

	shift

fi

if [ ! $# -eq 1 ] ; then

	echo -e "$USAGE" 1>&2
	exit 5

fi


echo "Looking for the '${type}' Erlang type from ${base_dir}..."
echo

/bin/find ${base_dir} -name '*.?rl' -exec /bin/grep -e "[[:space:]]\?-type[[:space:]]\+${type}()" '{}' ';' 2>/dev/null
