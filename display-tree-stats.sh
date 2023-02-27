#!/bin/sh

usage="Usage: $(basename $0) ROOT_DIR: displays key stats about the specified tree (typically in order to compare merged trees)."


root_dir="$1"

if [ -z "${root_dir}" ]; then

	echo -e "  Error, no root directory specified. ${usage}" 1>&2
	exit 5

fi

if [ ! -d "${root_dir}" ]; then

	echo -e "  Error, specified root directory ('${root_dir}') does not exist." 1>&2
	exit 10

fi

du -sh "${root_dir}"
tree "${root_dir}" 2>/dev/null | grep -e ' files$'
