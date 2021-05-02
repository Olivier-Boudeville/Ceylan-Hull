#!/bin/sh

usage="
Usage: $(basename $0) PREVIOUS_TEXT NEW_TEXT TARGET_FILE: replaces, in the specified file, the specified target pattern with the replacement one.

Example: $(basename $0) 'MAKE=' 'MAKE=/usr/bin/make' my_file"

# See also: replace-lines-starting-by.sh


if [ $# != 3 ]; then
	echo "${usage}" 1>&2
	exit 1
fi


target_file="$3"

if [ ! -f "${target_file}" ]; then
	echo "  Error, cannot operate on '${target_file}', which is not a regular file." 1>&2
	exit 2
fi

source_pattern="$1"
target_pattern="$2"

#echo "source_pattern = ${source_pattern}"
#echo "target_pattern = ${target_pattern}"
#echo "target_file = ${target_file}"

temp_file=".replace-in-file.tmp"

if [ -e "${temp_file}" ]; then

	echo "  Error, a '${temp_file}' file already exists. Please remove it first." 1>&2
	exit 3

fi

/bin/cp -f "${target_file}" "${temp_file}"

if [ ! $? -eq 0 ]; then

	echo "  Error, initial copy of '${target_file}' to '${temp_file}' failed." 1>&2
	exit 5

fi


/bin/cat "${temp_file}" | sed -e "s|${source_pattern}|${target_pattern}|g" > "${target_file}"
if [ ! $? -eq 0 ]; then

	echo "  Error, replacement in '${target_file}' failed." 1>&2
	exit 10

fi

/bin/rm -f "${temp_file}"

if [ ! $? -eq 0 ]; then

	echo "Error, removal of '${temp_file}' failed." 1>&2
	# Not fatal: exit 10

fi
