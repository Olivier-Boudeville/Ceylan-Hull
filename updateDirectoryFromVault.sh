#!/bin/bash

USAGE="\nUsage : `basename $0` <directory> : updates all files in specified directory from their vault counterparts."

# See : retrieve.sh, catch.sh

DATA_VAULT_DEFAULT="$HOME/Vault"

if [ -z "$DATA_VAULT" ] ; then
	echo "Warning : no vault environment variable specified (\$DATA_VAULT), choosing default one (${DATA_VAULT_DEFAULT})" 1>&2
	DATA_VAULT="${DATA_VAULT_DEFAULT}"
fi


if [ ! -d "$DATA_VAULT" ] ; then
	echo -e "Error, no vault directory found ($DATA_VAULT)." 1>&2
	exit 1
fi


if [ -z "$1" ] ; then
	echo -e "Error, no directory specified. $USAGE" 1>&2
	exit 2
fi
	
	
if [ ! -d "$1" ] ; then
	echo -e "Error, specified directory does not exist ($1)." 1>&2
	exit 3
fi
	 
cd $1

TARGET_FILES=`ls -A`


for f in ${TARGET_FILES} ; do
	if `ls ${DATA_VAULT}/$f 1>/dev/null 2>&1` ; then
		srm "$f"
		retrieve.sh "$f" 1>/dev/null
	fi
done

echo "Done !"
	 
