#!/bin/bash

USAGE="$0 <web root> : generates an html map from the available pages in <web root>"

WEB_ROOT=$1

echo

if [ -z "$WEB_ROOT" ]; then
	echo "$USAGE : error, not enough parameters"
	exit
fi

if [ ! -d "$WEB_ROOT" ]; then
	echo "$USAGE : error, $1 is not a directory"
	exit
fi

 
MAP_FILE="Map.html"
MAP_HEADER="$WEB_ROOT/../common/Map-header.html"
MAP_FOOTER="$WEB_ROOT/../common/Map-footer.html"


if [ ! -f "$MAP_HEADER" ] ; then
	echo "$USAGE : error for map header, file <$MAP_HEADER> does not exist"
	exit
fi

if [ ! -f "$MAP_FOOTER" ] ; then
	echo "$USAGE : error for map header, file <$MAP_FOOTER> does not exist"
	exit
fi

	
echo "Generating map file $MAP_FILE from $WEB_ROOT" 

cat $MAP_HEADER > $MAP_FILE

TARGET_FILES=`find $WEB_ROOT -name '*.html' -print`

echo "<ul>" >> $MAP_FILE

for f in $TARGET_FILES; do
	echo "    <li><a href="$f">`basename $f | sed 's|.html$||1'`</a></li>" >>  $MAP_FILE

done

echo "</ul>" >> $MAP_FILE

cat $MAP_FOOTER >> $MAP_FILE

echo "Map generated !"
