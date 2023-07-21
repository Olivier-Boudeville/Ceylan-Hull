#!/bin/sh


usage="Usage: $(basename $0) [-h|--help] TITLE: sets the title of the current terminal tab.
For example Gnome Terminal does not provide a graphical-based means of doing so."

if [ "$1" = "-h" ] || [ "$1" = "--help" ]; then

	echo "${usage}"

fi


if [ ! $# -eq 1 ]; then

	echo "  Error, a single argument (the title) is expected.
${usage}" 1>&2

	exit 5

fi

title="$1"
printf "\e]2;${title}\a" && echo "Terminal title updated to '${title}'."
