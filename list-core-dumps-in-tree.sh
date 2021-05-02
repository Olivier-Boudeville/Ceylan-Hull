#!/bin/sh

usage="Usage: $(basename $0): locates all core dump files in current tree."

echo
echo  "    tShowing all core dumps starting from $(pwd):"

cores=$(find . -name 'core*')

num=$(echo $cores | wc -w)

echo $num "core dumps found"
echo

if [ ! $num -eq 0 ]; then

	for c in $cores; do

		ls -l $c
		file $c
		echo
	done

fi
