#!/bin/bash


CP=/bin/cp
CAT=/bin/cat
SED=/bin/sed
RM=/bin/rm

USAGE="Usage : substitute.sh SOURCE TARGET FILE\n	replaces in FILE every symbol SOURCE by symbol TARGET \n example : \n\tsubstitute.sh wondrful wonderful myFile"
			 
if [ $# != 3 ]; then
	echo -e $USAGE
	exit 1
fi


if [ ! -f $3 ]; then
	echo -e "Cannot operate on '$3' which is not a regular file"
	exit 2
fi


# Currently not used anymore, since using '|' as a sed separator instead of '/'.
 
# Both scripts should be found in the same directory :
PROTECT_SCRIPT=`dirname $0`/protectSpecialCharacters.sh

if [ ! -x "${PROTECT_SCRIPT}" ]; then
	echo -e "Cannot find an executable protect script (${PROTECT_SCRIPT}) in "`pwd`
	exit 3
fi	


SOURCE=`${PROTECT_SCRIPT} "$1"`
TARGET=`${PROTECT_SCRIPT} "$2"`

#SOURCE="$1"
#TARGET="$2"

#echo "SOURCE = $SOURCE" && echo "TARGET = $TARGET" && echo "FILE   = $3" && exit

${CP} -f $3 tempSubstitute

${CAT} tempSubstitute | ${SED} -e "s/${SOURCE}/${TARGET}/g" > $3
#${CAT} tempSubstitute | ${SED} -e "s|${SOURCE}|${TARGET}|g" > $3

${RM} -f tempSubstitute
