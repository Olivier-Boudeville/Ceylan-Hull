#!/bin/sh

USAGE="
Usage: "`basename $0`" <previous text> <new text> FILE
	replaces in FILE <previous text> by <new text>

Example: 
	"`basename $0`" 'MAKE=' 'MAKE=/usr/bin/make' myFile"


if [ $# != 3 ]; then
	echo "$USAGE" 1>&2
	exit 1
fi


target_file="$3"

if [ ! -f "${target_file}" ]; then
	echo "Cannot operate on ${target_file}, which is not a regular file." 1>&2
	exit 2
fi

SOURCE="$1"
TARGET="$2"

#echo "SOURCE = $SOURCE"
#echo "TARGET = $TARGET"
#echo "FILE   = $3"

temp_file=".replace-in-file.tmp"

/bin/cp -f ${target_file} ${temp_file}
if [ ! $? -eq 0 ] ; then

	echo "Error, initial copy of ${target_file} to ${temp_file} failed." 1>&2
	exit 5
	
fi


/bin/cat ${temp_file} | sed -e "s|$SOURCE|$TARGET|g" > ${target_file}
if [ ! $? -eq 0 ] ; then

	echo "Error, replacement in ${target_file} failed." 1>&2
	exit 10
	
fi


/bin/rm -f ${temp_file}
if [ ! $? -eq 0 ] ; then

	echo "Error, removal of ${temp_file} failed." 1>&2
	# Not fatal: exit 10
	
fi

