#!/bin/sh


USAGE="Usage: $(basename $0) A_TARGET: tracks changes on the source file in order to regenerate the target accordingly."


WAITER=$(which inotifywait 2>/dev/null)

if [ ! -x "${WAITER}" ] ; then

	echo "    Error, inotifywait not found; inotify-tools package lacking?" 1>&2
	exit 5

fi



if [ ! $# -eq 1 ] ; then

	echo "    Error, exactly one source file must be specified." 1>&2
	exit 10

fi


SOURCE_FILE="$1"

if [ ! -f "${SOURCE_FILE}" ] ; then

	echo "    Error, specified source file '${SOURCE_FILE}' not found." 1>&2
	exit 15

fi

# Currently supports only *.rst -> *.pdf transformations:

TARGET_FILE=$(echo "${SOURCE_FILE}" | sed 's|.rst$|.pdf|1')

if [ "${SOURCE_FILE}" = "${TARGET_FILE}" ] ; then

	echo "    Error, source and target files are the same ('${SOURCE_FILE}')." 1>&2
	exit 20

fi

echo "Will track ${SOURCE_FILE}: at each of its modifications the generation of ${TARGET_FILE} will requested..."

# To force a first build (better than a touch detected by the editor):
if [ -f "${TARGET_FILE}" ] ; then

	/bin/rm -f "${TARGET_FILE}"

fi


while true ; do

	  echo
	  echo "- regenerating ${TARGET_FILE} on $(date)"
	  make ${TARGET_FILE}
	  ${WAITER} -e modify ${SOURCE_FILE} 1>/dev/null 2>&1

done
