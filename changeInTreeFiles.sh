#!/bin/sh

USAGE="$0 <file pattern> <source expression> <target expression>"

if [ ! "$#" -eq "3" ] ; then
	echo "Error, $USAGE" 
	exit
fi

find . -type f -name "$1" -print | while read i
do
   # echo "s|$2|$3|g"
   sed "s|$2|$3|g" $i > $i.tmp && mv $i.tmp $i
   # mv was cp before
done

