#!/bin/sh

# Consider using W3C link checker
# (http://validator.w3.org/checklink)

USAGE="$0 <starting directory>"

if [ -z "$1" ]; then
	echo $USAGE
	exit
fi

RESULT="~/tmp/result.html"
OPTIONS="-output $RESULT -HTMLoutput"

echo "Searching for broken links from $1...."
find "$1" -name '*.html' -exec deadlinkcheck $OPTIONS '{}' ';'

echo "You can now find results in $RESULT"
