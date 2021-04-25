#!/bin/sh

usage="Usage: $(basename $0) SNAPSHOT_FILENAME: renames the specified picture file, based on its embedded date (used as a prefix, if appropriate), and with a proper extension. New assigned names are typically '20160703-foo-bar.jpeg'.
"

if [ ! $# -eq 1 ]; then

	echo "  Error, exactly one argument needed. ${usage}" 1>&2

	exit 5

fi

filename="$1"

if [ ! -f "${filename}" ]; then

	echo "  Error, '${filename}' is not an existing file." 1>&2

	exit 10

fi

expanded_filename=$(realpath "${filename}")

#echo "Expanding input filename '${filename}' into '${expanded_filename}'."


# Do not add a date prefix if there is already one:

test_prefix=$(echo $(basename "${filename}" ) | sed 's|^[0-9]*-.*||1')

#echo "test_prefix = ${test_prefix}"

if [ -z "${test_prefix}" ]; then

	# Already a prefix, thus none added:
	prefix=""

else

	exiftool=$(which exiftool 2>/dev/null)

	if [ ! -x "${exiftool}" ]; then

		echo "  Error, no executable 'exiftool' found." 1>&2

		exit 15

	fi

	# Two possible patterns, such as:
	# "Create Date                     : 2011:12:04 08:50:40"
	# "GPS Date Stamp                  : 2011:12:04"
	#
	# Sometimes there may be only:
	# "File Modification Date/Time     : 2014:10:28 21:45:47+01:00"

	# Like "20180702":
	prefix=$(${exiftool} "${expanded_filename}" | grep 'GPS Date Stamp\|Create Date' | sed 's|^.*: ||1' | sed 's| .*$||1' | sed 's|:||g')

	if [ -n "${prefix}" ]; then
		prefix="${prefix}-"
	fi

	#echo "prefix = '${prefix}'"

fi

extension=$(echo "${filename}" | sed 's|.*\.||1')

#echo "detected extension = ${extension}"

all_but_extension=$(echo "${filename}" | sed 's|\.[^\.]*$||1')

#echo "all but extension = ${all_but_extension}"


if [ "${extension}" = "jpg" ] || [ "${extension}" = "JPG" ] || [ "${extension}" = "JPEG" ]; then

	extension="jpeg"

fi

#echo "retained extension = ${extension}"

if [ -n "${prefix}" ]; then

	# The original filename may already include the just determined prefix; if so,
	# let's remove that potential duplication:
	#
	new_basename=$(basename "${all_but_extension}" | sed "s|${prefix}||1")

fi


new_filename="$(dirname ${expanded_filename})/${prefix}$(basename ${all_but_extension}).${extension}"

#echo "new filename = ${new_filename}"

if [ -e "{new_filename}" ]; then

	echo "  Error, new filename for '${expanded_filename}', i.e. '${new_filename}', already exists." 1>&2

	exit 20

fi


if [ ! "${expanded_filename}" = "${new_filename}" ]; then

	/bin/mv "${expanded_filename}" "${new_filename}"


	if [ ! $? -eq 0 ]; then

		echo "  Error, renaming '${expanded_filename}' into '${new_filename}' failed." 1>&2

		exit 25

	fi

	echo "'${expanded_filename}' has been renamed as '${new_filename}'."

else

	echo "('${expanded_filename}' kept as is)"

fi
