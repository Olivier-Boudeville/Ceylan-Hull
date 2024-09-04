#!/bin/sh

resulting_ext="tar.xz.gpg"

date_prefix="$(date "+%Y%m%d")"

usage="Usage: $(basename $0) [-h|--help] [-e|--exclude EXCLUDED_ENTRY] DIRECTORY_TREE_TO_SNAPSHOT: performs a snapshot of the specified filesystem tree, i.e. creates a corresponding timestamped ${resulting_ext} archive.

  Any number of excludes, relative to the target directory, can be specified.

  Example: '$(basename $0) -e foo -e \"**/bar/baz\" osdl' will produce a ${date_prefix}-osdl-snapshot.${resulting_ext} archive of the 'osdl' tree in the current directory, excluding osdl/foo and osdl/**/bar/baz."


crypt_name="crypt.sh"

crypt_tool="$(which ${crypt_name} 2>/dev/null)"

if [ ! -x "${crypt_tool}" ]; then

	echo "  Error, no executable crypt tool ('${crypt_name}') found." 1>&2
	exit 4

fi


if [ "$1" = "-h" ] || [ "$1" = "--help" ]; then

	echo "${usage}"
	exit

fi


excludes=""

token_eaten=0

while [ $token_eaten -eq 0 ]; do

	token_eaten=1

	if [ "$1" = "-e" ] || [ "$1" = "--exclude" ]; then

		shift

		if [ -z "$1" ]; then

			echo "  Error, exclude option specified, but no element could be found after it." 1>&2

			exit 10

		fi

		# Do not ever type to protect $1 with ' or \", tar would take them
		# literally:
		#
		excludes="${excludes} --exclude=$1"

		shift

		token_eaten=0

	fi

done


target_dir="$1"

if [ -z "${target_dir}" ]; then

	echo "  Error, no directory to snapshot specified.
${usage}" 1>&2

	exit 15

fi

shift


if [ ! $# -eq 0 ]; then

	echo " Error, extra parameters specified: $*.
${usage}" 1>&2

	exit 20

fi


if [ ! -d "${target_dir}" ]; then

	echo "  Error, the specified directory ('${target_dir}') to snapshot does not exist.
${usage}" 1>&2
	exit 6

fi


archive_name="${date_prefix}-$(basename ${target_dir})-snapshot.tar.xz"
#echo "archive_name = ${archive_name}"


# A bit of black magic about exclusions despite shell variables; only the third
# form works:

#extra_opts="--exclude={*.jpg,*.jpeg,*.JPG}"

#extra_opts="--exclude='*.jpg' --exclude='*.jpeg' --exclude='*.JPG'"

# The only right one:
#extra_opts="--exclude=*.jpg --exclude=*.jpeg --exclude=*.JPG --exclude=*.png --exclude=*.bmp --exclude=*.gif --exclude=*.bz2 --exclude=*.gz --exclude=*.zip --exclude=*.xz --exclude=*.rar --exclude=*.iso --exclude=*.gpg --exclude=*.pack --exclude=*.mp4 --exclude=*.ogg --exclude=*.backup --exclude=*.apk --exclude=*.img"

extra_opts="${excludes}"


if [ -n "${extra_opts}" ]; then

	echo "Using the following extra options: ${extra_opts}"

fi


# /usr/bin/tar generally:
if ! tar ${extra_opts} -cvJf "${archive_name}" "${target_dir}"; then

	echo "  Error, the archive creation failed." 1>&2
	exit 7

fi

"${crypt_tool}" "${archive_name}" && echo "Snapshot file ${archive_name}.gpg is ready!"
