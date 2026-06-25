#!/bin/sh

usage="Usage: $(basename $0) [-h|--help] [TITLE]: sets the title of the current terminal tab.

Useful, as for example Gnome Terminal does not provide any graphical-based means of doing so.

If no title is specified, the uppercased version of the name of the current directory will be used.

Does nothing with xfce4-terminal."


if [ "$1" = "-h" ] || [ "$1" = "--help" ]; then

	echo "${usage}"

	exit

fi


if [ ! $# -le 1 ]; then

	echo "  Error, extra parameter(s) specified.
${usage}" 1>&2

	exit 5

fi


title="$1"

if [ -z "${title}" ]; then

	title="$(echo $(basename $(pwd)) | tr '[:lower:]' '[:upper:]')"

fi

printf "\e]2;${title}\a" && echo "Terminal title updated to '${title}'."
