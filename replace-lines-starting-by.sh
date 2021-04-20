#/bin/sh

usage="
Usage: $(basename $0) START TARGET FILE
		.

Example: $(basename $0) 'MAKE=' 'MAKE=/usr/bin/make' myFile"

# See also: replace-in-file.sh


if [ $# != 3 ]; then
	echo "${usage}" 1>&2
	exit 1
fi


target_file="$3"

if [ ! -f "${target_file}" ]; then
	echo "  Cannot operate on ${target_file}, which is not a regular file." 1>&2
	exit 2
fi

shell_dir=$(dirname $0)

SOURCE="^$(${shell_dir}/protect-special-characters.sh "$1").*$"
TARGET=$(${shell_dir}/protect-special-characters.sh "$2")

#echo "SOURCE = $SOURCE"
#echo "TARGET = $TARGET"
#echo "FILE   = $3"

temp_file=".replace-lines-starting-by.tmp"

/bin/cp -f ${target_file} ${temp_file}

/bin/cat ${temp_file} | sed -e "s|$SOURCE|$TARGET|g" > ${target_file}

/bin/rm -f ${temp_file}
