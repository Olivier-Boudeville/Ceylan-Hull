#!/bin/bash

USAGE="Usage : substituteInFiles.sh <OldPattern> <NewPattern>\nSubstitute <OldPattern> with <NewPattern> in all files, starting recursively from current directory\nExample : \n\tsubstituteInFiles.sh wondrful wonderful\n\tsubstituteInFiles.sh '<< endl )$' '<< endl ) ;'"

if [ ! $# -eq 2 ]; then
	echo -e $USAGE
	exit 
fi

# substitute in all files $1 with $2
#example : substituteInFiles.sh wondrful wonderful 

echo -e "Will substitute <$1> with <$2> in following tree : "
tree

unset value
read -p "Let's proceed with substitution ? (y/n) [n]" value
if [ "$value" == "y" ]; then
	echo "Substituing..."
	find . -type f -name '*' -exec substitute.sh "$1" "$2" '{}' ';'
	echo "... finished"
else
	echo "Cancelled"
fi

unset value
