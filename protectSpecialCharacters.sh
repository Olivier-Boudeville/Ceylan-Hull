#!/bin/bash

USAGE="Usage : protectSpecialCharacters.sh EXPR\n	prevent special characters  in EXPR  from being interpreted by tools like sed \n example : \n\tprotectSpecialCharacters.sh eee/dd/f \n\tshould output eee\/dd\/f"

SED=/usr/bin/sed
if [ ! -x "${SED}" ] ; then
	SED=/usr/bin/sed
fi


if [ $# != 1 ]; then
	echo -e $USAGE
	exit 1
fi


# Replaces '/' by '\/' :

#echo $1 | ${SED} 's/\//\\\//g'
echo $1 | ${SED} 's|/|\\/|g'
