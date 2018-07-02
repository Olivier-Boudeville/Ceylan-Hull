#!/bin/sh

USAGE="
Usage: $(basename $0) SNAPSHOT_FILENAME: renames the specified picture file, based on its date, and with a proper extension.
"

if [ ! $# -eq 1 ] ; then

	echo "  Error, exactly one argument needed. $USAGE" 1>&2

	exit 5

fi

filename="$1"

if [ ! -e "${filename}" ] ; then

	echo "  Error, file '${filename}' does not exist." 1>&2

	exit 10

fi

exiftool=$(which exiftool 2>/dev/null)

if [ ! -x "${exiftool}" ] ; then

	echo "  Error, no executable 'exiftool' found." 1>&2

	exit 15

fi


# Like "20180702":
prefix=$(${exiftool} "${filename}" | grep 'GPS Date Stamp' | sed 's|^.*: ||1' | sed 's|:||g')

#echo "prefix = '${prefix}'"


extension=$(echo "${filename}" | sed 's|.*\.||1')

#echo "detected extension = ${extension}"

all_but_extension=$(echo "${filename}" | sed 's|\.[^\.]*$||1')

#echo "all but extension = ${all_but_extension}"


if [ "${extension}" = "jpg" ] || [ "${extension}" = "JPG" ] || [ "${extension}" = "JPEG" ] ; then

	extension="jpeg"

fi

#echo "retained extension = ${extension}"


new_filename="$(dirname ${filename})/${prefix}-$(basename ${all_but_extension}).${extension}"

#echo "new filename = ${new_filename}"

if [ -e "{new_filename}" ]; then

	echo "  Error, new filename for '${filename}', i.e. '${new_filename}', already exists." 1>&2

	exit 20

fi

/bin/mv "${filename}" "${new_filename}"

if [ ! $? -eq 0 ]; then

	echo "  Error, renaming '${filename}' into '${new_filename}' failed." 1>&2

	exit 25

fi

echo "'${filename}' has been renamed as '${new_filename}'."
