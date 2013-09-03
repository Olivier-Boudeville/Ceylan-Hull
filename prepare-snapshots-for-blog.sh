#!/bin/sh 

USAGE=$(basename $0)" [-d]: reduce the size of JPEG files found in current directory. If the -d option is specified, the original files will be deleted."

do_delete=1

if [ $1 = "-r" ] ; then

	echo "Original files will be deleted."
	do_delete=0

fi


TARGETS=$(/bin/ls -1 *.jpeg | grep -v 'reduced.jpeg')
#echo "TARGETS = ${TARGETS}"

TOOL=$(which prepare-snapshot-for-blog.sh)
#echo "TOOL = ${TOOL}"

if [ ! -x "${TOOL}" ] ; then

	echo "   Error, conversion script not found." 1>&2

	exit 5

fi

for f in ${TARGETS} ; do ${TOOL} $f ; done

if [ $do_delete -eq 0 ] ; then

	/bin/rm -f ${TARGETS}

fi



