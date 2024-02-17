#!/bin/sh

usage="Usage: $(basename $0): runs Scilab; sandboxes it, as it may have been obtained thanks to an AppImage, which may or may not be trusted; supposes that firejail is available for that."

if [ "$1" = "-h" ] || [ "$1" = "--help" ]; then

	echo "${usage}"

	exit 0

fi


if [ ! "$#" -eq 0 ]; then

	echo "  Error, unexpected argument specified.
${usage}"

	exit 2

fi


firejail="$(which firejail 2>/dev/null)"

if [ ! -x "${firejail}" ]; then

	echo "  Error, no 'firejail' executable found, whereas this tool is to use it in order to sandbox the scilab AppImage (Arch hint: 'pacman -Sy firejail')." 1>&2

	exit 5

fi

scilab_exec="Scilab-x86_64.AppImage"

# As per our installation conventions:
scilab="$(PATH=${HOME}/Software/scilab:${PATH} which ${scilab_exec} 2>/dev/null)"

if [ ! -x "${scilab}" ]; then

	echo "  Error, no scilab ('${scilab_exec}') executable found. See https://github.com/davidcl/Scilab.AppDir/releases." 1>&2

	exit 15

fi


echo "(running '${scilab}', as found in PATH)"

"${firejail}" --appimage "${scilab}" &
