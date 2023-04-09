#!/bin/sh

usage="Usage: $(basename $0) [-h|--help] [fr|us|...]: sets the keyboard layout for the current X session (hence for all applications, including the running ones, like terminals)."

if [ "$1" = "-h" ] || [ "$1" = "--help" ]; then

	echo "${usage}"

	exit

fi


if [ -z "$1" ]; then

	echo "  Error, no layout specified.
${usage}" 1>&2

	exit 5

fi

layout="$1"

setter_tool="/bin/setxkbmap"

if [ ! -x "${setter_tool}" ]; then

	echo "  Error, no setxkbmap found." 1>&2

	exit 5

fi

${setter_tool} "${layout}"
