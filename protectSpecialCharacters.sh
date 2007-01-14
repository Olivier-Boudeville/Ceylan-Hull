#!/bin/sh

USAGE="
Usage : protectSpecialCharacters.sh EXPR
Prevents special characters in EXPR from being interpreted by tools like sed.
example : 
	protectSpecialCharacters.sh eee/dd/f 
	should output eee\/dd\/f"

SED=/bin/sed
if [ ! -x "${SED}" ] ; then
	SED=/usr/bin/sed
fi


if [ $# != 1 ]; then
	echo $USAGE
	exit 1
fi


# Replaces '/' by '\/' :

#echo $1 | ${SED} 's/\//\\\//g'
echo $1 | ${SED} 's|/|\\/|g'
