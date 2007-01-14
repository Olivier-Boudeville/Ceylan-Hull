#!/bin/sh

# Default : in english
# -f : in french

if [ "$1" = "-f" ] ; then
	LANG=fr_FR
	date '+%A %-e %B %Y'
else
	LANG=
	date '+%A, %B %-e, %Y'
fi
