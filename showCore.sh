#!/bin/sh

echo
echo -e "\tShowing all core dumps starting from `pwd` :"

cores=`find . -name 'core*'`

num=`echo $cores | wc -w`

echo $num "core dumped found"
echo

if [ ! $num -eq "0" ]; then

	for c in $cores; do

		ls -l $c
		file $c	
		echo
	done

fi


 
