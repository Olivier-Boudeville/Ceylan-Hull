#!/bin/sh

usage="Usage: $(basename $0) [-h|--help] FILE_ELEMENT [FILE_ELEMENT]: removes any metadata (typically EXIF) stored in the specified snapshot(s), which are thus modified in-place; snapshots are specified as a list of file elements, each being either a file or a directory, in which case all files found recursively from this root directory and whose extension is .jpg or .jpeg (regardless of their case) will have their metadata removed"

if [ $# -eq 0 ]; then

	echo "  Error, no snapshot specified.
${usage}" 1>&2
	exit 5

fi

if [ "$1" = "-h" ] || [ "$1" = "--help" ]; then

	echo "${usage}"
	exit 0

fi

exif_tool="exiftool"

exif_tool_exec="$(which ${exif_tool})"

if [ ! -x "${exif_tool_exec}" ]; then

	echo "  Error, no EXIF tool ('${exif_tool}') available." 1>&2
	exit 5

fi

exif_tool_opt="-overwrite_original -all="

for e in $*; do

	if [ -f "$e" ]; then

		echo " - removing EXIF metadata from file '$e'"
		${exif_tool_exec} ${exif_tool_opt} "$e"

		if [ ! $? -eq 0 ]; then
			echo "  Error, removal for file '$e' failed." 1>&2
			exit 10
		fi

	elif [ -d "$e" ]; then

		echo " - removing EXIF metadata in tree '$e'..."

		find "$e" -type f \( -iname \*.jpg -o -iname \*.jpeg \) -exec echo '  * removing EXIF metadata from file' {} \; -exec ${exif_tool_exec} ${exif_tool_opt} '{}' ';'

		if [ ! $? -eq 0 ]; then
			echo "  Error, removal for tree '$e' failed." 1>&2
			exit 15
		fi

	else

		echo "(ignoring '$e')"

	fi

done

echo "EXIF metadata removed."
