#!/bin/sh

# Just to remember the command:

if [ -z "$1" ] ; then

	echo "Usage: "$(basename $0)" [fr|us|...]: sets the X keyboard layout."

	exit 0

fi

TOOL="/bin/setxkbmap"

if [ ! -x "$TOOL" ] ; then

	echo "  Error, no setxkbmap found." 1>&2

	exit 5

fi

$TOOL $1
