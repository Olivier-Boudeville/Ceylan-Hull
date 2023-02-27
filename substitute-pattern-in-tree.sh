#!/bin/sh

usage="
  Usage: $(basename $0) <OldPattern> <NewPattern>
Substitutes every source pattern by specified target one in all files, starting recursively from current directory.
  Example:
	$(basename $0) wondrful wonderful
	$(basename $0) '<< endl )$' '<< endl ) ;'"


if [ ! $# -eq 2 ]; then

	echo ${usage} 1>&2
	exit 5

fi


echo "Will substitute <$1> with <$2> in following tree: "
tree

unset value
read -p "Let's proceed with substitution? (y/n) [n]" value

if [ "$value" = "y" ]; then

	echo "Substituing..."
	find . -type f -name '*' -exec substitute-pattern-in-file.sh "$1" "$2" '{}' ';'
	echo "... finished"

else

	echo "Cancelled." 1>&2
	exit 1

fi
