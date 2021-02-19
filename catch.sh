#!/bin/sh

usage="Usage: $(basename $0) FILE: stores a file in a vault directory and makes a symbolic link to it, so that even if current tree is removed, this file will not be lost."

# Any already caught file with the same name will be overwritten.

# See: retrieve.sh, update-directory-from-vault.sh.

data_vault_default="${HOME}/hull-vault"


if [ ! $# -eq 1 ]; then
	echo "  Error, not exactly one argument provided.
${usage}" 1>&2
	exit 1
fi

target="$1"

if [ ! -f "${target}" ]; then

	echo "  Error, no file '${target}' to catch.
${usage}" 1>&2

	exit 5

fi


if [ -z "$data_vault" ]; then

	echo "Warning: no vault environment variable specified (\$data_vault), choosing default one (${data_vault_default})" 1>&2

	data_vault="${data_vault_default}"

fi

mkdir -p "${data_vault}"


echo "Catching ${target}..."

/bin/mv -f "${target}" ${data_vault} && ln -sf ${data_vault}/$(basename ${target}) ${target} && echo "... done"
