#!/bin/sh

USAGE="
Usage : substituteInFiles.sh <OldPattern> <NewPattern>
Substitutes <OldPattern> with <NewPattern> in all files, starting recursively from current directory
Example : 
	substituteInFiles.sh wondrful wonderful
	substituteInFiles.sh '<< endl )$' '<< endl ) ;'"

if [ ! $# -eq 2 ]; then
	echo -e $USAGE
	exit 
fi

# substitute in all files $1 with $2
#example : substituteInFiles.sh wondrful wonderful 

echo "Will substitute <$1> with <$2> in following tree : "
tree

unset value
read -p "Let's proceed with substitution ? (y/n) [n]" value
if [ "$value" = "y" ]; then
	echo "Substituing..."
	find . -type f -name '*' -exec substitute.sh "$1" "$2" '{}' ';'
	echo "... finished"
else
	echo "Cancelled"
fi

unset value
