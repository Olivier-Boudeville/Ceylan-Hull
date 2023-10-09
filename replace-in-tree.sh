#!/bin/sh

usage="Usage: $(basename $0) [-h|--help] FILE_PATTERN SOURCE_EXPR TARGET_EXPR: replaces, in files whose name matches the specified pattern found from the current directory, the specified source pattern with the target one.
For example: $(basename $0) '*.java' 'List<' 'Map<'"

if [ "$1" = "-h" ] || [ "$1" = "--help" ]; then

	echo "${usage}"

	exit 5

fi


if [ ! $# -eq 3 ]; then
	echo "  Error, three parameters are expected.
${usage}" 1>&2
	exit 5
fi


file_pattern="$1"
source_pattern="$2"
target_pattern="$3"

echo "Replacing, in files matching '${file_pattern}', patterns matching '${source_pattern}' with '${target_pattern}'..."

find . -type f -name "${file_pattern}" -print | while read i
do

	echo "  - replacing in ${i}"

	tmp_file="${i}.replace.tmp"

	if [ -e "${tmp_file}" ]; then

		echo "  Error, a '${tmp_file}' element already exists, remove it first." 1>&2
		exit 10

	fi

	sed "s|${source_pattern}|${target_pattern}|g" "${i}" > "${tmp_file}" && /bin/mv "${tmp_file}" "${i}"

done

echo "Replacements done."
