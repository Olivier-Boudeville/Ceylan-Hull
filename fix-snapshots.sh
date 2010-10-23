#!/bin/sh

USAGE="Usage: "`basename $0`" PREFIX [DATE]: takes care of all snapshots found from current directory, so that they respect better conventions.
Ex: '"`basename $0`" hello 20101023'  will transform picture filenames like P1010695.JPG into 20101023-hello-695.jpeg, and will ensure it is not an executable file.
Should no date be specified, the current day will be used instead.
"

prefix="$1"

if [ -z "$prefix" ] ; then

	echo "Error, no prefix for snapshots was specified.
$USAGE" 1>&2
	exit 5

fi


photos=`find . -name '*.JPG'`

# You can also override it with a constant date:
date="$2"

if [ -z "$date" ] ; then
	date=`date '+%Y%m%d'`
	echo "  Warning: no date specified, using current day ($date) instead."
fi

for f in $photos; do

	chmod -x $f
	/bin/mv $f `echo $f | sed 's|.JPG$|.jpeg|1' | sed "s|P1010|$date-$prefix-|1"`

	if [ ! $? -eq 0 ] ; then
		echo "Error, renaming failed." 1>&2
		exit 10
	fi

done

echo "  Snapshots successfully fixed!"
