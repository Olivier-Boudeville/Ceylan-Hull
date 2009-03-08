#!/bin/sh

USAGE="
Usage: "`basename $0`" filename
  Removes any silence at begin and end of specified file, which is updated (initial content is thus lost).
"


target_file="$1"

if [ -z "${target_file}" ] ; then
	
	echo "Error, no target file specified. ${USAGE}" 1>&2
	exit 10
	
fi


if [ ! -f "${target_file}" ] ; then

	echo "Error, target file (${target_file}) not found." 1>&2
	exit 11

fi


# Prefer any recently self-compiled version:
sox_tool=`PATH=/usr/local/bin:$PATH which sox 2>/dev/null`

if [ ! -x "${sox_tool}" ] ; then

	echo "Error, sox tool not found." 1>&2
	exit 12

fi


echo "Trimming beginning and ending silences from ${target_file}"

tmp_file=".trimSilence.tmp.wav"

decibel_threshold="-40"

# Reversing to find silences in both directions:

${sox_tool} ${target_file} ${tmp_file} silence 1 0:0:0.01 ${decibel_threshold}d reverse && ${sox_tool} ${tmp_file} ${target_file} silence 1 0:0:0.01 ${decibel_threshold}d reverse

if [ $? -eq 0 ] ; then
	echo "${target_file} successfully generated."
else
	echo "Error, trimming of ${target_file} failed." 1>&2
	exit 20
fi		


/bin/rm -r ${tmp_file}

