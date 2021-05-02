#!/bin/sh

usage="Usage: $(basename $0) DIR: updates all files in specified directory from their vault counterparts."

# See: retrieve.sh, catch.sh

data_vault_default="${HOME}/hull-vault"

if [ -z "${data_vault}" ]; then

	echo "  Warning: no vault environment variable specified (\${data_vault}), choosing default one (${data_vault_default})." 1>&2

	data_vault="${data_vault_default}"

fi


if [ ! -d "${data_vault}" ]; then

	echo "  Error, no vault directory found (${data_vault})." 1>&2
	exit 5

fi


if [ -z "$1" ]; then

	echo "  Error, no directory specified.
${usage}" 1>&2

	exit 10

fi

target_dir="$1"

if [ ! -d "${target_dir}" ]; then

	echo "  Error, specified directory does not exist (${target_dir})." 1>&2

	exit 15

fi

cd "${target_dir}"

target_files=$(/bin/ls -A)

for f in ${target_files}; do

	if /bin/ls ${data_vault}/$f 1>/dev/null 2>&1; then
		srm "$f"
		retrieve.sh "$f" 1>/dev/null
	fi

done

echo "Done !"
