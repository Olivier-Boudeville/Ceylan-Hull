#/bin/bash

USAGE="Usage : replaceLineStartingBy.sh START TARGET FILE\n	replaces in FILE every line starting by START by line TARGET\n example : \n\t replaceLineStartingBy.sh "MAKE=" "MAKE=/usr/bin/make" myFile"

if [ $# != 3 ]; then
	echo -e $USAGE
	exit 1
fi

if [ ! -f $3 ]; then
	echo -e "Cannot operate on $3 which is not a regular file"
	exit 1
fi

shell_dir=`dirname $0`

SOURCE="^"`${shell_dir}/protectSpecialCharacters.sh "$1"`".*$"
TARGET=`${shell_dir}/protectSpecialCharacters.sh "$2"`

#echo "SOURCE = $SOURCE"
#echo "TARGET = $TARGET"
#echo "FILE   = $3"

cp $3 tempSubstituteReplace
cat tempSubstituteReplace | sed -e "s/$SOURCE/$TARGET/g" >$3
rm tempSubstituteReplace
