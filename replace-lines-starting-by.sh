#/bin/sh

usage="
Usage: $(basename $0) START_OF_LINE TARGET_LINE TARGET_FILE

Example: $(basename $0) 'MAKE=' 'MAKE=/usr/bin/make' myFile"

# See also: replace-in-file.sh


if [ $# != 3 ]; then
	echo " Error, 3 parameters expected.
${usage}" 1>&2
	exit 5
fi


target_file="$3"

if [ ! -f "${target_file}" ]; then
	echo "  Error, cannot operate on '${target_file}', which is not an existing regular file." 1>&2
	exit 10
fi

shell_dir="$(dirname $0)"

source="^$(${shell_dir}/protect-special-characters.sh "$1").*$"
target_line=$(${shell_dir}/protect-special-characters.sh "$2")

#echo "source = ${source}"
#echo "target_line = ${target_line}"
#echo "target_file = ${target_file}"

temp_file=".replace-lines-starting-by.tmp"

/bin/cp -f "${target_file}" "${temp_file}"

/bin/cat "${temp_file}" | sed -e "s|${source}|${target_line}|g" > "${target_file}"

/bin/rm -f "${temp_file}"
