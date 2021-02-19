#!/bin/sh

usage="$(basename $0): $(basename $0) [fr|us|...]: sets the X keyboard layout."

# Just to remember the command:

if [ -z "$1" ]; then

	echo "No layout specified.
${usage}" 1>&2

	exit 5

fi

layout="$1"

setter_tool="/bin/setxkbmap"

if [ ! -x "${setter_tool}" ]; then

	echo "  Error, no setxkbmap found." 1>&2

	exit 5

fi

${setter_tool} ${layout}
