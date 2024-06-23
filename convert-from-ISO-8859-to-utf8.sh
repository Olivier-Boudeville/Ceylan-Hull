#!/bin/sh

# Source format needed, otherwise 'iconv: illegal input sequence at position
# XXX':
#
#source_format="ISO-8859-1"
source_format="ASCII"

target_format="utf-8"

usage="Usage: $(basename $0) [-h|--help] TEXT_FILE: converts (in-place) the specified (text) file from a ${source_format} format to a ${target_format} one."

# Emacs can be used as well to convert text files to UTF-8: use mouse-3 on the
# bottom, leftmost clickable area, or select ‘C-x C-m f’.


if [ "$1" = "-h" ] || [ "$1" = "--help" ]; then

	echo "${usage}"
	exit

fi



iconv="$(which iconv 2>/dev/null)"

if [ ! -x "${iconv}" ]; then

	echo "  Error, no 'iconv' executable available." 1>&2

	exit 5

fi



if [ -z "$1" ]; then

	echo "  Error, no argument specified.
${usage}" 1>&2

	exit 10

fi



source_file="$1"

if [ ! -f "${source_file}" ]; then

	echo "  Error, file '${source_file}' does not exist." 1>&2

	exit 15

fi

shift


if [ -n "$*" ]; then

	echo "  Error, extra arguments specified ('$*')." 1>&2

	exit 25

fi



tmp_file="${source_file}.tmp"

# No '-f' intentionally:

/bin/mv "${source_file}" "${tmp_file}" && iconv -f "${source_format}"  -t "${target_format}" "${tmp_file}" > "${source_file}" && echo "File '${source_file}' converted!"
