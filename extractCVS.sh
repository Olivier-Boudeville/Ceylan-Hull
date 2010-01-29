#!/bin/sh

USAGE="`basename $0` <absolute path to CVSROOT>: extracts data from a CVS repository thanks to an export."

if [ -z "$1" ] ; then
	echo "Error, no repository specified. $USAGE"
	exit 1
fi

if [ ! -d "$1" ] ; then
	echo "Error, the specified repository does not exist ($1). $USAGE"
	exit 2
fi


for d in `ls $1`; do
	if [ "$d" != "$CVSROOT" ]; then
		echo "    exporting module $d"
		cvs -Q -d$1 export -D TOMORROW $d 
	fi	
done	
