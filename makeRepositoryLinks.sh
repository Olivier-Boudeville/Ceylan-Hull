#!/bin/sh

USAGE="`basename $0` makes links from an already existing LOANI vault to avoid downloading archive files uselessly. This script is to be used for LOANI's debugging purpose."

if [ -z "${VAULT}" ] ; then
	VAULT="$HOME/tmp/LOANI-Vault"
fi

if [ ! -d ${VAULT} ] ; then
	echo "Error, no LOANI vault found (expected ${VAULT})." 1>&2
	echo "$USAGE" 1>&2
	exit 1
fi

echo "$USAGE"

mkdir -p LOANI-repository 

cd LOANI-repository

#echo "In `pwd` :"

for f in ${VAULT}/LOANI-repository/* ; do
	echo "    + linking $f"
	ln -s $f 2>/dev/null
done

echo "Links to archive done"
