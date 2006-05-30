#!/bin/bash

USAGE="Usage : "`basename $0`" [<file>+] : retrieves at least one file already stored in vault by creating link towards it, from current directory. No previous file with the same name should exist."

# See : catch.sh, updateDirectoryFromVault.sh


DATA_VAULT_DEFAULT="$HOME/Vault"

if [ -z "$DATA_VAULT" ] ; then
	echo "Warning : no vault environment variable specified (\$DATA_VAULT), choosing default one (${DATA_VAULT_DEFAULT})" 1>&2
	DATA_VAULT="${DATA_VAULT_DEFAULT}"
fi

echo

while [ -n "$1" ] ; do

	linkTarget="$1"

	if [ -e "${linkTarget}" ] ; then
		echo "Error, ${linkTarget} already exists, remove it first. $USAGE"
		exit 1
	fi

	if [ ! -f ${DATA_VAULT}/`basename ${linkTarget}` ] ; then
		echo "Error, no "`basename ${linkTarget}`" previously caught, refusing to create a dead link."
		exit 2
	fi

	ln -s ${DATA_VAULT}/`basename ${linkTarget}` ${linkTarget} && echo "    Linked back to ${DATA_VAULT}/`basename $linkTarget`"

	shift 
done
