#!/bin/sh

usage="Usage: $(basename $0) DIR: performs a snapshot (tar.xz.gpg archive) of specified directory.
  Example: $(basename $0) MY_DIR"


crypt_name="crypt.sh"

crypt_tool=$(which ${crypt_name} 2>/dev/null)


if [ ! -x "$crypt_tool" ]; then

	echo "  Error, no executable crypt tool (${crypt_name}) found." 1>&2
	exit 5

fi


if [ ! $# -eq 1 ]; then

	echo "  Error, exactly one parameter expected.
${usage}" 1>&2
	exit 10

fi


target_dir="$1"

if [ ! -d "${target_dir}" ]; then

	echo "  Error, specified directory (${target_dir}) does not exist.
${usage}" 1>&2
	exit 15

fi

date=$(date "+%Y%m%d")

archive_name="$date-$(basename $target_dir)-snapshot.tar.xz"
#echo "archive_name = ${archive_name}"

/bin/tar cvJf "${archive_name}" "${target_dir}"

if [ ! $? -eq 0 ]; then

	echo "  Error, archive creation failed." 1>&2
	exit 20

fi

${crypt_tool} "${archive_name}" && echo "Snapshot file '${archive_name}.gpg' is ready!"
