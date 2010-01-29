#!/bin/sh

echo "Will make so that all files from current directory ("`pwd`") are not executable, namely:"

find . -type f -exec echo '{}' ';'

read -e -p "     Proceed ? (y/n) [n]" value

if [ "$value" = "y" ]; then
	echo "Changing rights..."
	find . -type f -exec chmod -x '{}' ';'
	echo "Done, no more executable files !"
else
	echo "Cancelled !"
	
fi


		

