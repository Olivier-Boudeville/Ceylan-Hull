#!/bin/sh

fix_script_name="fix-filename.sh"

usage="Usage: $(basename $0) [-h|--help] [-f|--fix] ELEM_DIR [TARGET_ELEM_NAME] [DEST_DIR]: moves the most recent element (file or directory) found in the ELEM_DIR directory in any specified DEST_DIR directory, otherwise in the current directory.

The -f / --fix option will lead to the moved element being also \"fixed\", i.e. properly renamed thanks to our ${fix_script_name} script.

If TARGET_ELEM_NAME is specified, the element will be renamed accordingly, otherwise its name will be preserved.

Examples:

 '$(basename $0) ~/Downloads foo.pdf my-documents' will move any latest-modified element in ~/Downloads to my-documents/foo.pdf
 '$(basename $0) /tmp' will move any latest-modified element in /tmp in the current directory (with the same name)
"


if [ "$1" = "-h" ] || [ "$1" = "--help" ]; then

	echo "  ${usage}"
	exit

fi


fix=1

if [ "$1" = "-f" ] || [ "$1" = "--fix" ]; then

	shift

	fix_script="$(which ${fix_script_name} 2>/dev/null)"

	if [ ! -x "${fix_script}" ]; then

		echo "  Error, the name of the moved element is requested to be fixed, but our '${fix_script_name}' script is not found in the PATH." 1>&2

		exit 2

	fi

	#echo "(the name of the moved element will also be fixed)"
	fix=0

fi




elem_dir="$1"

if [ -z "${elem_dir}" ]; then

	echo "  Error, no source directory specified.
${usage}" 1>&2

	exit 10

fi


if [ ! -d "${elem_dir}" ]; then

	echo "  Error, the specified source directory, '${elem_dir}', does not exist.
${usage}" 1>&2

	exit 15

fi



# Lastly modified element (just its name, no path):
last_element="$(/bin/ls -rt ${elem_dir} | tail -n1)"

#echo "Last element: '${last_element}'."

source_path="${elem_dir}/${last_element}"

#echo "Found source path: '${source_path}'."

if [ ! -e "${source_path}" ]; then

	echo "  Error, no (lastly-modified) element found in the specified source directory, '${elem_dir}'." 1>&2

	exit 25

fi



target_element="$2"

if [ -z "${target_element}" ]; then

	target_element="${last_element}"

fi


dest_dir="$3"

if [ -z "${dest_dir}" ]; then

	dest_dir="."

elif [ ! -d "${dest_dir}" ]; then

	echo "  Error, the specified target source directory, '${dest_dir}', does not exist.
${usage}" 1>&2

	exit 20

fi


target_path="${dest_dir}/${target_element}"

#echo "Targeting '${target_path}'."

if [ -e "${target_path}" ]; then

	echo "  Error, the target path, '${target_path}', already exists." 1>&2

	exit 30

fi

if /bin/mv -f "${source_path}" "${target_path}"; then

	echo "  Moved '${source_path}' to '${target_path}'."

else

	echo "  Error, failed to move '${source_path}' to '${target_path}'." 1>&2

	exit 35

fi


if [ $fix -eq 0 ]; then

	"${fix_script}" "${target_path}"

fi
