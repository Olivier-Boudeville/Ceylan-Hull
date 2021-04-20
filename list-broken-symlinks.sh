#!/bin/sh

usage="Usage: $(basename $0) [-q|--quiet] [ROOT_DIR]: lists, from any specified directory otherwise from the current one, all the symbolic links that are broken (i.e. that do not point to an existing filesystem element).
In quiet mode (typically for scripting), only lists the found links, if any (no extra message)
"

quiet=1

if [ "$1" = "-q" ] || [ "$1" = "--quiet" ]; then

	quiet=0
	shift

fi

if [ -n "$1" ]; then

	root_dir="$1"
	shift

else

	root_dir="$(pwd)"

fi


if [ -n "$1" ]; then

	echo "  Error, too many arguments.
${usage}" 1>&2

	exit 5

fi


[ $quiet -eq 0 ] || echo "  Listing broken symbolic links from '${root_dir}':"

find ${root_dir} -xtype l
