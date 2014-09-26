#!/bin/sh

USAGE="Usage: "$(basename $0)": toggles the touchpad activation state."

CLIENT=$(which synclient 2>/dev/null)

if [ ! -x "$CLIENT" ] ; then

	echo "  Error, no synclient found." 1>&2

	exit 5

fi


# Quick and dirty, yet working:
if $CLIENT -l | grep TouchpadOff | grep '= 1' 1>/dev/null ; then

	$CLIENT TouchpadOff=0
	echo "Touchpad enabled."

else

	$CLIENT TouchpadOff=1
	echo "Touchpad disabled."

fi
