#!/bin/sh


USAGE="Usage : "`basename $0`" [<directory to html tidy>] : will apply tidy on each file of the specified directory. If none is specified, will operate in current working directory."

# See : http://tidy.sourceforge.net/

DIR="."

TIDYUPDATE=`which tidyupdate.sh 2>/dev/null`

echo 

if [ -z "$TIDYUPDATE" ]; then
	echo "Error, no tidyupdate script found, please update your path or the path in this script."
	exit 1
fi

if [ ! -x "$TIDYUPDATE" ]; then
	echo "Error, tidyupdate script ($TIDYUPDATE) is not executable."
	exit 2
fi


if [ -n "$1" ]; then
	
	if [ ! -d "$1" ]; then
		echo "Error, $1 is not a directory. $USAGE"
		exit 3
	fi
	
	DIR="$1"
	echo "Tidying in $1 ..."
else
	echo "Tidying current directory `pwd` ..."
fi	
	
for f in *.html; do
	echo
	echo "####  Tyding $f"
	$TIDYUPDATE $f
	
done

echo 
echo "Tidy done."
