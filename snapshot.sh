#!/bin/sh

resulting_ext="tar.xz.gpg"

date_prefix="$(date "+%Y%m%d")"

usage="Usage: $(basename $0) [-h|--help] DIRECTORY_TREE_TO_SNAPSHOT: performs a snapshot of the specified filesystem tree, i.e. creates a corresponding timestamped ${resulting_ext} archive.
  Example: '$(basename $0) osdl' will produce a ${date_prefix}-osdl-snapshot.${resulting_ext} archive in the current directory."


crypt_name="crypt.sh"

crypt_tool="$(which ${crypt_name} 2>/dev/null)"

if [ ! -x "${crypt_tool}" ]; then

	echo "    Error, no executable crypt tool (${crypt_name}) found." 1>&2
	exit 4

fi


if [ ! $# -eq 1 ]; then

	echo "    Error, exactly one parameter expected.
${usage}" 1>&2
	exit 5

fi

if [ ! $# -eq 1 ]; then

	echo "    Error, exactly one parameter expected.
${usage}" 1>&2
	exit 5

fi

if [ "$1" = "-h" ] || [ "$1" = "--help" ]; then

	echo "${usage}"
	exit

fi


target_dir="$1"

if [ ! -d "${target_dir}" ]; then

	echo "    Error, the specified directory ('${target_dir}') does not exist.
${usage}" 1>&2
	exit 6

fi


archive_name="${date_prefix}-$(basename ${target_dir})-snapshot.tar.xz"
#echo "archive_name = ${archive_name}"

if ! tar cvJf "${archive_name}" "${target_dir}"; then

	echo "    Error, archive creation failed." 1>&2
	exit 7

fi

"${crypt_tool}" "${archive_name}" && echo "Snapshot file ${archive_name}.gpg is ready!"
