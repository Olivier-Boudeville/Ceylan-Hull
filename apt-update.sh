#!/bin/sh

# Tired of typing it:


if [ `id -u` -eq 0 ] ; then

	echo "Updating the distribution now..."

	apt-get update && apt-get -y upgrade
	
	echo "...done"
	
else

	echo "You must be root!" 1>&2
	exit 1
	
fi
		
