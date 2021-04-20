#!/bin/sh


usage="
Usage: $(basename $0) SOURCE_PATTERN TARGET_PATTERN FILE
  Replaces in specified file every source pattern by specified target one.
Example:
  $(basename $0) wondrful wonderful myFile.txt
"


CP=/bin/cp
CAT=/bin/cat

SED=/bin/sed

if [ ! -x "${SED}" ]; then
	SED=/usr/bin/sed
fi

RM=/bin/rm


if [ $# != 3 ]; then

	echo "Error, three parameters needed, whereas provided ones were: $*.
${usage}" 1>&2
	exit 1

fi

target_file="$3"

if [ ! -f "${target_file}" ]; then

	echo "Error, cannot operate on '${target_file}' which is not a regular file.
${usage}" 1>&2
	exit 2

fi


# Currently not used anymore, since using '|' as a sed separator instead of '/'.

# Both scripts should be found in the same directory:
PROTECT_SCRIPT=$(dirname $0)/protect-special-characters.sh

if [ ! -x "${PROTECT_SCRIPT}" ]; then
	echo "
	Error, cannot find an executable protect script (${PROTECT_SCRIPT}) in $(pwd) 1>&2
	exit 3
fi


SOURCE=$(${PROTECT_SCRIPT} "$1")
TARGET=$(${PROTECT_SCRIPT} "$2")

#SOURCE="$1"
#TARGET="$2"

#echo "SOURCE = $SOURCE" && echo "TARGET = $TARGET" && echo "FILE   = $3" && exit

temp_file=".substitute-pattern-in-file.tmp"

${CP} -f ${target_file} ${temp_file}

#${CAT} ${temp_file} | ${SED} -e "s/${SOURCE}/${TARGET}/g" > ${target_file}
${CAT} ${temp_file} | ${SED} -e "s|${SOURCE}|${TARGET}|g" > ${target_file}

${RM} -f ${temp_file}
