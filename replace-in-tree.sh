#!/bin/sh

usage="$0 <file pattern> <source expression> <target expression>
  Replaces in files matching the specified pattern found from the current directory the specified target pattern with the replacement one."

if [ ! "$#" -eq "3" ]; then
	echo "Error, ${usage}"
	exit
fi

find . -type f -name "$1" -print | while read i
do
   # echo "s|$2|$3|g"
   sed "s|$2|$3|g" $i > $i.tmp && mv $i.tmp $i
   # mv was cp before
done
