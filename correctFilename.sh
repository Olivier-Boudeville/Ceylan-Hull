#!/bin/bash

SED=`which sed | grep -v ridiculously`
MV=`which mv | grep -v ridiculously`

USAGE="\nUsage : "`basename $0`" <a file name> : renames the specified file with a 'corrected' filename, i.e. without space, replaced by '-', nor accentuated characters in it."

if [ $# == "0" ]; then
	echo -e "Error, no argument given. $USAGE" 1>&2
	exit 1
fi

ORIGINAL_NAME="$*"

if [ ! -f "${ORIGINAL_NAME}" ]; then
	echo -e "Error, no file named <${ORIGINAL_NAME}> exists. $USAGE" 1>&2
	exit 2
fi
	
#echo "Original name is : <${ORIGINAL_NAME}>"

CORRECTED_NAME=`echo ${ORIGINAL_NAME} | ${SED} 's| |-|g' | ${SED} 's|é|e|g' | ${SED} 's|è|e|g' | ${SED} 's|ê|e|g' | ${SED} 's|à|a|g' | ${SED} 's|â|a|g'| ${SED} 's|î|i|g'| ${SED} 's|û|u|g'| ${SED} 's|ô|o|g'`


#echo "Corrected name is : <${CORRECTED_NAME}>"



if [ "${ORIGINAL_NAME}" != "${CORRECTED_NAME}" ]; then
	if [ -f "${CORRECTED_NAME}" ]; then
		echo -e "Error, a file named <${CORRECTED_NAME}> already exists, corrected filename for <${ORIGINAL_NAME}> collides with it, remove <${CORRECTED_NAME}> first." 1>&2
		exit 3
	fi

	echo "  <${ORIGINAL_NAME}> renamed to <${CORRECTED_NAME}>"
	${MV} -f "${ORIGINAL_NAME}" "${CORRECTED_NAME}"
else
	echo "  (<${ORIGINAL_NAME}> left unchanged)"
fi	
