#!/bin/sh

SOURCE=$1

if [ ! -f "${SOURCE}" ] ; then

	echo "   Error, source file (${SOURCE}) does not exist." 1>&2
	exit 5

fi

TARGET=$(echo ${SOURCE} | sed 's|\.jpeg$|-reduced.jpeg|1')

#echo "TARGET = ${TARGET}"

if [ -f "${TARGET}" ] ; then

	echo "   Error, target file (${TARGET}) already exists, remove it first." 1>&2
	exit 10

fi

CONVERT=$(which convert)

if [ ! -x "${CONVERT}" ] ; then

	echo "   Error, 'convert' tool not found." 1>&2
	exit 15

fi
	
${CONVERT} "${SOURCE}" -resize 50% -quality 0.9 "${TARGET}"

if [ ! $? -eq 0 ] ; then

	echo "    Error, conversion of $SOURCE failed." 1>&2
	exit 20

else

	echo " + $TARGET generated"

fi
