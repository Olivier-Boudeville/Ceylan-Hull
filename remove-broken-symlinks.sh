#!/bin/sh

usage="Usage: $(basename $0) ROOT_DIR: removes from the specified directory all the symbolic links that are broken (i.e. that do not point to an existing filesystem element).
"



if [ ! $# -eq 1 ]; then

	echo "  Error, exactly one argument expected.
${usage}" 1>&2

	exit 5

fi

root_dir="$1"

if [ ! -d "${root_dir}" ]; then

	echo "  Error, directory '${root_dir}' does not exist.
${usage}" 1>&2

	exit 6

fi

echo "  Removing broken symbolic links from '${root_dir}':"

find ${root_dir} -xtype l -exec /bin/rm -f '{}' ';'
