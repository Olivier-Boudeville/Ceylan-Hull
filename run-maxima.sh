#!/bin/sh

usage="Usage: $(basename $0): runs Maxima, thanks to a GUI (based on a sandboxed wxmaxima AppImage; supposes that firejail is available for that), otherwise directly on the command-line."

if [ "$1" = "-h" ] || [ "$1" = "--help" ]; then

	echo "${usage}"

	exit 0

fi


if [ ! "$#" -eq 0 ]; then

	echo "  Error, unexpected argument specified.
${usage}"

	exit 2

fi


wxmaxima_img="wxmaxima-x86_64.AppImage"

wxmaxima_img_path="${HOME}/Software/maxima/${wxmaxima_img}"

if [ -e "${wxmaxima_img_path}" ]; then

	firejail="$(which firejail 2>/dev/null)"

	if [ ! -x "${firejail}" ]; then

		echo "  Error, no 'firejail' executable found, whereas this tool is to use it in order to sandbox the wxmaxima AppImage (Arch hint: 'pacman -Sy firejail')." 1>&2

		exit 5

	fi

	echo " (launching a sandboxed wxmaxima AppImage)"
	"${firejail}" --appimage "${wxmaxima_img_path}" &

else

	echo " (no wxmaxima GUI found, defaulting to command-line)"

	maxima="$(which maxima 2>/dev/null)"

	if [ ! -x "${maxima}" ]; then

		echo "  Error, no maxima  executable found (Arch hint: 'pacman -Sy maxima')." 1>&2

		exit 15

	fi

fi

echo " Running maxima (enter 'quit();' to exit)"
"${maxima}"
