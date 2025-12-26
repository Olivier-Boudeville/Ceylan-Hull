#!/bin/sh

# Copyright (C) 2019-2026 Olivier Boudeville
#
# Author: Olivier Boudeville [olivier (dot) boudeville (at) esperide (dot) com]
#
# This file is part of the Ceylan-Hull toolbox (see http://hull.esperide.org).


# Preferring not a blind transformation on any binary file (e.g. .beam, .o, .so,
# executables, etc.).

target_extensions="txt markdown md asciidoc spec erl hrl java escript app edoc rst src config js css json mk"

target_filenames="Makefile pom.xml rebar.config .gitignore LICENSE"


usage="Usage: $(basename $0) [-h|--help] ROOT_DIRECTORY: fixes whitespace problems in all eligible files found from the specified root directory tree.

Useful, when operating on a fork, to properly whitespace-format files once for all and commit the result so that these formatting changes remain cleanly and clearly separated from the upcoming meaningful others.

Target extensions are: '${target_extensions}'.
Target filenames are: '${target_filenames}'.
"

if [ "$1" = "-h" ] || [ "$1" = "--help" ]; then

	echo "${usage}"
	exit

fi

target_dir="$1"

if [ ! $# -eq 1 ]; then

	echo "  Error, exactly one parameter needed.
${usage}" 1>&2

	exit 5

fi


if [ ! -d "${target_dir}" ]; then

	echo "  Error, directory '${target_dir}' not found." 1>&2
	exit 10

fi


fix_script_name="fix-whitespaces.sh"

#fix_script="$(which ${fix_script_name} 2>/dev/null)"
fix_script="$(dirname $0)/${fix_script_name}"

if [ ! -x "${fix_script}" ]; then

	echo " Error, no '${fix_script_name}' script found (searched as '${fix_script}')." 1>&2

	exit 20

fi

cd "${target_dir}"

echo "  Fixing whitespaces in files found from '$(pwd)':"


echo " - whose extension is in '${target_extensions}'..."

ext_expr="find . \( $(for e in ${target_extensions}; do echo "-name '*.$e' -o "; done) -false \) -exec ${fix_script} '{}' ';'"

#echo "ext_expr = ${ext_expr}"

eval ${ext_expr}



echo " - whose name is in '${target_filenames}'..."

name_expr="find . \( $(for f in ${target_filenames}; do echo "-name '$f' -o "; done) -false \) -exec ${fix_script} '{}' ';'"

#echo "name_expr = ${name_expr}"

eval ${name_expr}
