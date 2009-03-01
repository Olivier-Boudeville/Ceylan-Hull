#/bin/sh

USAGE="
Usage: replaceLineStartingBy.sh START TARGET FILE
	replaces in FILE every line starting by START by line TARGET

Example: 
	replaceLineStartingBy.sh 'MAKE=' 'MAKE=/usr/bin/make' myFile"


if [ $# != 3 ]; then
	echo "$USAGE" 1>&2
	exit 1
fi


target_file="$3"

if [ ! -f "${target_file}" ]; then
	echo "Cannot operate on ${target_file}, which is not a regular file." 1>&2
	exit 2
fi

shell_dir=`dirname $0`

SOURCE="^"`${shell_dir}/protectSpecialCharacters.sh "$1"`".*$"
TARGET=`${shell_dir}/protectSpecialCharacters.sh "$2"`

#echo "SOURCE = $SOURCE"
#echo "TARGET = $TARGET"
#echo "FILE   = $3"

temp_file=".replaceLineStartingBy.tmp"

/bin/cp -f ${target_file} ${temp_file}

/bin/cat ${temp_file} | sed -e "s|$SOURCE|$TARGET|g" > ${target_file}

/bin/rm -f ${temp_file}

