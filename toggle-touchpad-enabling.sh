#!/bin/sh

usage="Usage: $(basename $0) [-h|--help]: toggles the touchpad activation state."

if [ "$1" = "-h" ] || [ "$1" = "--help" ]; then

	echo "${usage}"
	exit

fi

if [ "$1" ]; then

	echo "  Error, extra parameter specified.
${usage}" 1>&2

	exit 5

fi


client="$(which synclient 2>/dev/null)"

if [ ! -x "${client}" ]; then

	echo "  Error, no 'synclient' executable found." 1>&2
	exit 15

fi


# Quick and dirty, yet working:
if ${client} -l | grep TouchpadOff | grep '= 1' 1>/dev/null; then

	${client} TouchpadOff=0
	echo "Touchpad enabled."

else

	${client} TouchpadOff=1
	echo "Touchpad disabled."

fi
