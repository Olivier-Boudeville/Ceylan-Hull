#!/bin/sh

MAP_FILE="Map.html"

USAGE="$0 <web root>: generates an html map from the available pages in <web root>, and generates a $MAP_FILE file in the current directory."

WEB_ROOT=$1

echo

if [ -f "$MAP_FILE" ] ; then
	echo "Error, a $MAP_FILE file already exists, remove it first."
	exit 1
fi

if [ -z "$WEB_ROOT" ] ; then
	echo "$USAGE: error, not enough parameters"
	exit 2
fi

if [ ! -d "$WEB_ROOT" ] ; then
	echo "$USAGE: error, $1 is not a directory"
	exit 3
fi

 
MAP_HEADER="$WEB_ROOT/../common/Map-header.html"
MAP_FOOTER="$WEB_ROOT/../common/Map-footer.html"


if [ ! -f "$MAP_HEADER" ] ; then
	echo "$USAGE: error for map header, file <$MAP_HEADER> does not exist"
	exit 4
fi

if [ ! -f "$MAP_FOOTER" ] ; then
	echo "$USAGE: error for map header, file <$MAP_FOOTER> does not exist"
	exit 5
fi

	
echo "Generating map file $MAP_FILE from $WEB_ROOT" 

cat $MAP_HEADER > $MAP_FILE

TARGET_FILES=`find $WEB_ROOT -name '*.html' -print | grep -v index.htm | grep -v Menu`

echo "<ul>" >> $MAP_FILE

for f in $TARGET_FILES; do
	echo "    <li><a href="$f">`basename $f | sed 's|.html$||1'`</a></li>" >>  $MAP_FILE

done

echo "</ul>" >> $MAP_FILE

cat $MAP_FOOTER >> $MAP_FILE

echo "Map generated ! ($MAP_FILE)"
