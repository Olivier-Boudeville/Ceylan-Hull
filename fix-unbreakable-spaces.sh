#!/bin/sh

USAGE="
Usage: "`basename $0`" FILE
	converts all unbreakable spaces in FILE into normal spaces.
	They are often created by mistake when using French keyboards and typing Shift+AltGr+Space."


if [ $# != 1 ]; then
	echo "$USAGE" 1>&2
	exit 1
fi


target_file="$1"

if [ ! -f "${target_file}" ]; then
	echo "Cannot operate on ${target_file}, which is not a regular file." 1>&2
	exit 2
fi


temp_file=".fix-unbreakable-in-file.tmp"

/bin/cp -f ${target_file} ${temp_file}
if [ ! $? -eq 0 ] ; then

	echo "Error, initial copy of ${target_file} to ${temp_file} failed." 1>&2
	exit 5
	
fi


/bin/cat ${temp_file} | sed 's| | |g' > ${target_file}
if [ ! $? -eq 0 ] ; then

	echo "Error, replacement in ${target_file} failed." 1>&2
	exit 10
	
fi


/bin/rm -f ${temp_file}
if [ ! $? -eq 0 ] ; then

	echo "Error, removal of ${temp_file} failed." 1>&2
	# Not fatal: exit 10
	
fi

