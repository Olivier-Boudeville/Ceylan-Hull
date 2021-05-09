#!/bin/sh

# Preferring not a blind transformation on any binary file (ex: beam, o,
# executables, etc.).

target_extensions="txt markdown md asciidoc spec erl hrl escript app edoc rst src config js json mk"

target_filenames="Makefile rebar.config .gitignore LICENSE"


usage="Usage: $(basename $0) A_DIRECTORY: fixes whitespace problems in all elligible files found from specified root directory tree.
Useful, when operating on a fork, to properly format files once for all and commit the result so that these formatting changes remain cleanly and clearly separated from the others.
Target extension are '${target_extensions}', target filenames are '${target_filenames}'.
"

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
