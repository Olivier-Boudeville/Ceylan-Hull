#!/bin/sh

usage="Usage: $(basename $0) FILE [FILE]: retrieves at least one file already stored in vault by creating link towards it, from current directory. No previous file with the same name should exist."

# See: catch.sh, update-directory-from-vault.sh.


data_vault_default="${HOME}/hull-vault"

if [ -z "${data_vault}" ]; then

	echo "  Warning: no vault environment variable specified (\${data_vault}), selecting default one (${data_vault_default})." 1>&2

	data_vault="${data_vault_default}"

fi

echo

while [ -n "$1" ]; do

	link_target="$1"

	if [ -e "${link_target}" ]; then

		echo "  Error, ${link_target} already exists, remove it first.
${usage}"

		exit 5

	fi

	if [ ! -f "${data_vault}/$(basename ${link_target})" ]; then

		echo "  Error, no $(basename ${link_target}) previously caught, refusing to create a dead link." 1>&2

		exit 10

	fi

	ln -sf ${data_vault}/$(basename ${link_target}) ${link_target} && echo "    Linked back to ${data_vault}/$(basename ${link_target})."

	shift

done
