#!/bin/sh


usage="Usage: $(basename $0) RST_SOURCE_FILE: converts specified RST source file (e.g. 'foobar.rst') in a mediawiki counterpart file (e.g. 'foobar.mediawiki')."


pandoc="$(which pandoc)"

if [ ! -x "${pandoc}" ]; then

	echo "  Error, no pandoc tool found." 1>&2
	exit 5

fi


if [ ! $# -eq 1 ]; then

	echo "  Error, exactly one parameter expected.
${usage}" 1>&2
	exit 10

fi


source_file="$1"

if [ ! -f "${source_file}" ]; then

	echo "  Error, specified source file ('${source_file}') not found." 1>&2
	exit 15

fi


# Any pre-existing mediawiki file will be silently overwritten:
target_file=$(echo "${source_file}" | sed 's|\.rst$|.mediawiki|1')

#echo "target_file = ${target_file}"

export LANG=fr_FR.utf8

echo " - converting '${source_file}' to '${target_file}'"
${pandoc} --from=rst --to=mediawiki "${source_file}" -o "${target_file}"

if [ ! $? -eq 0 ]; then

	echo "  Conversion of '${source_file}' failed." 1>&2
	exit 50

fi
