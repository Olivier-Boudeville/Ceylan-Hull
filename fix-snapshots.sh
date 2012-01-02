#!/bin/sh

USAGE="
Usage: "`basename $0`" OLD_PREFIX NEW_PREFIX [DATE]: takes care of all snapshots found from current directory, so that they respect better conventions.
Ex: '"`basename $0`" P1010 hello 20101023'  will transform picture filenames like P1010695.JPG into 20101023-hello-695.jpeg, and will ensure it is not an executable file.
Should no date be specified, the current day will be used instead.
"

if [ $# -ge 4 ] ; then

	echo "
Error, too many parameters specified.
$USAGE" 1>&2
	exit 4

fi

old_prefix="$1"

if [ -z "$old_prefix" ] ; then

	echo "
Error, no previous prefix (OLD_PREFIX) for snapshots was specified.
$USAGE" 1>&2
	exit 5

fi


new_prefix="$2"

if [ -z "$new_prefix" ] ; then

	echo "
Error, no replacement prefix (NEW_PREFIX) for snapshots was specified.
$USAGE" 1>&2
	exit 6

fi

photos=`find . -iname '*.JPG'`

#echo "photos = $photos"


# You can also override it with a constant date:
date="$3"

if [ -z "$date" ] ; then
	date=`date '+%Y%m%d'`
	echo "
  Warning: no date specified, using current day ($date) instead."
fi

echo "  Renaming now snapshots bearing old prefix '$old_prefix' into ones with new prefix '$new_prefix' and time-stamp '$date'."

for f in $photos; do

	chmod -x $f
	# 'I' means 'case insensitive' as 'JPG' *and* 'jpg' are interesting us:
	target_file=`echo $f | sed 's|.JPG$|.jpeg|1' | sed "s|$old_prefix|$date-$new_prefix-|1"`

	if [ "$f" = "$target_file" ] ; then

		echo "  ('$f' name left as is by renaming rule)"

	else

		/bin/mv "$f" "$target_file"

		if [ ! $? -eq 0 ] ; then
			echo "Error, renaming failed." 1>&2
			exit 10
		fi

	fi


done

echo "  Snapshots successfully fixed!"
echo "  New snapshot filenames are:
"`ls`
