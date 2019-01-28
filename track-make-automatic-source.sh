#!/bin/sh

pdf_opt="--pdf"

usage="Usage: $(basename $0) [${pdf_opt}] MY_TARGET_RST_FILE: tracks changes on the RST source file in order to regenerate the target file accordingly. By default, the target file is the corresponding HTML one. Using the ${pdf_opt} option allows to generate the a PDF target instead."


waiter=$(which inotifywait 2>/dev/null)

if [ ! -x "${waiter}" ] ; then

	echo "    Error, inotifywait not found; inotify-tools package lacking?" 1>&2
	exit 5

fi

target_ext="html"

if [ $# -eq 2 ] ; then

	if [ "$1" = "--pdf" ] ; then
		echo "Switching to PDF target"
		target_ext="pdf"
	else
		echo "    Error, unexpected option ($1)." 1>&2
		echo "$usage" 1>&2
		exit 8
	fi

	shift

fi

if [ ! $# -eq 1 ] ; then

	echo "    Error, exactly one RST source file must be specified." 1>&2
	echo "$usage" 1>&2
	exit 10

fi


source_file="$1"

if [ ! -f "${source_file}" ] ; then

	echo "    Error, specified source file '${source_file}' not found." 1>&2
	exit 15

fi

# Currently supports only *.rst -> *.pdf transformations:

target_file=$(echo "${source_file}" | sed "s|.rst$|.${target_ext}|1")

if [ "${source_file}" = "${target_file}" ] ; then

	echo "    Error, source and target files are the same ('${source_file}')." 1>&2
	exit 20

fi

echo "Will track ${source_file}: at each of its modifications the generation of ${target_file} will requested..."

# To force a first build (better than a touch detected by the editor):
if [ -f "${target_file}" ] ; then

	/bin/rm -f "${target_file}"

fi


if [ "${target_ext}" = "pdf" ]; then

	message="  (${target_file} regenerated)"

else

	message="  (${target_file} regenerated, reload this page on your browser!)"

fi


while true ; do

	  echo
	  echo "- regenerating ${target_file} on $(date)"

	  # Note: the local GNUmakefile shall include
	  # Ceylan-Myriad/doc/GNUmakerules-docutils.inc.
	  #
	  make ${target_file} && echo "${message}"

	  ${waiter} -e modify ${source_file} 1>/dev/null 2>&1

done
