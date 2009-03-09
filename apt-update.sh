#!/bin/sh

# Tired of typing it:

if [ `id -u` -eq 0 ] ; then
	apt-get update && apt-get upgrade
else
	echo "Must be root!" 1>&2
	exit 1
fi
		
