#!/bin/sh

current_date="$(date '+%Y%m%d')"

usage="Usage: $(basename $0) OLD_PREFIX NEW_PREFIX [DEFAULT_DATE]: renames snapshots found from current directory, so that they respect better naming conventions.
Ex: '$(basename $0) P1010 hello 20101023' will transform picture filenames like P1010695.JPG into 20101023-hello-695.jpeg, and will ensure it is not an executable file.
If a creation timestamp can be found among the image EXIF metadata, it will be retained, otherwise the specified date will be used, otherwise the current date (${current_date}) will be.
"

if [ $# -ge 4 ]; then

	echo "
Error, too many parameters specified.
${usage}" 1>&2
	exit 4

fi

old_prefix="$1"

if [ -z "${old_prefix}" ]; then

	echo "
Error, no previous prefix (OLD_PREFIX) for snapshots was specified.
${usage}" 1>&2
	exit 5

fi


new_prefix="$2"

if [ -z "${new_prefix}" ]; then

	echo "
Error, no replacement prefix (NEW_PREFIX) for snapshots was specified.
${usage}" 1>&2
	exit 6

fi

snapshots=$(find . -iname '*.JPG' -o -iname '*.jpeg')

#echo "snapshots = ${snapshots}"


# Any user-specified date as default:
default_date="$3"

if [ -z "${default_date}" ]; then

	echo "No date specified, the default will be the current one, ${current_date}."
	default_date="${current_date}"

else

	string_len=$(echo -n ${default_date} | wc -m)

	if [ ! ${string_len} -eq 8 ]; then

		echo "  Error, default date expected to be 8-character long (had '${date}')." 1>&2
		exit 8

	fi

fi



echo "  Renaming now snapshots bearing old prefix '${old_prefix}' into ones with new prefix '${new_prefix}' and default timestamp '$default_date'."

for f in ${snapshots}; do

	exif_date=$(file "$f" | sed 's|.* datetime=||1' | sed 's| .*$||1' | sed 's|:||g')

	# We expect the date to be like "20181020", hence to be 8-character long:
	string_len=$(echo -n ${exif_date} | wc -m)

	if [ ${string_len} -eq 8 ]; then

		suffix="EXIF"
		date="${exif_date}"
		#echo "Date extracted from EXIF information: '${date}'."

	else

		suffix="default"
		date="${default_date}"
		#echo "No suitable date could be found in EXIF information (got '${exif_date}'), using default date (${default_date}) instead."

	fi

	chmod -x $f

	target_file=$(echo $f | sed 's|.JPG$|.jpeg|1' | sed 's|.JPEG$|.jpeg|1' | sed 's|.jpg$|.jpeg|1' | sed "s|${old_prefix}|${date}-${new_prefix}-|1")


	if [ "$f" = "${target_file}" ]; then

		echo "  ('$f' name left as is by renaming rule)"

	else

		# To remove useless './'s:
		message=$(echo "    $f -> ${target_file} (${suffix})"| sed 's|./||g')
		echo "${message}"

		/bin/mv "$f" "${target_file}"

		if [ ! $? -eq 0 ]; then
			echo "Error, renaming failed." 1>&2
			exit 10
		fi

	fi


done

echo "  Snapshots successfully fixed!"
#echo "  New snapshot filenames are:
#$(ls)"
