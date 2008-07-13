#!/bin/sh

USAGE=`basename $0`": stores a file in a vault directory and makes a symbolic link to it, so that if current tree is erased, this file will be kept."

# See: retrieve.sh, updateDirectoryFromVault.sh

DATA_VAULT_DEFAULT="$HOME/Vault"


if [ ! "$#" = "1" ] ; then
	echo "Error, not exactly one argument provided. $USAGE"
	exit 1
fi	

if [ -z "$DATA_VAULT" ] ; then
	echo "Warning: no vault environment variable specified (\$DATA_VAULT), choosing default one (${DATA_VAULT_DEFAULT})" 1>&2
	DATA_VAULT="${DATA_VAULT_DEFAULT}"
fi

mkdir -p "$DATA_VAULT"

target="$1"

if [ ! -f "$1" ] ; then
	echo "Error, no file <$1> to catch. $USAGE"
	exit 3
fi

echo "Catching $target ..."


mv -f "$target" $DATA_VAULT && ln -s $DATA_VAULT/`basename $target` $target && echo "... done"

