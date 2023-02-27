#!/bin/sh

action="ensures that all files found recursively from the current directory $(pwd) are not executable"

usage="Usage: $(basename $0): ${action} (typically useful after a vfat transfer)"

echo "This script ${action}, namely:"

find . -type f -exec echo '{}' ';'

read -e -p "     Proceed ? (y/n) [n]" value

if [ "$value" = "y" ]; then

	echo "Changing permissions..."
	find . -type f -exec chmod -x '{}' ';'
	echo "Done, no more executable files."

else

	echo "Cancelled."

fi
