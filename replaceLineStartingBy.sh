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


SOURCE="^"`protectSpecialCharacters.sh "$1"`".*$"
TARGET=`protectSpecialCharacters.sh "$2"`

#echo "SOURCE = $SOURCE"
#echo "TARGET = $TARGET"
#echo "FILE   = $3"

cp $3 tempSubstituteReplace
cat tempSubstituteReplace | sed -e "s/$SOURCE/$TARGET/g" >$3
rm tempSubstituteReplace
