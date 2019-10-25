#!/bin/sh

usage="Usage: $(basename $0) [level]: activates the keyboard backlighting (0% for level 1, 50% for level 1, 100% for level 2 (the default)."

#echo $usage

if [ ! $(id -u) -eq 0 ] ; then

	echo "  Error, you must be root." 1>&2
	exit 5

fi

CTRL=$(which brightnessctl 2>/dev/null)

if [ ! -x "${CTRL}" ] ; then

	echo "  Error, 'brightnessctl' tool not available. One may use: 'pacman -Sy brightnessctl'." 1>&2
	exit 10

fi

level="$1"

if [ -z "${level}" ] ; then

	level=2

fi

echo "Setting brightness level to ${level}."
${CTRL} --device='tpacpi::kbd_backlight' set ${level}

res=$?

if [ $res -eq 0 ] ; then

	echo "(success)"

else

	echo "Error, setting failed (code: $res)." 1>&2
	exit 15

fi
