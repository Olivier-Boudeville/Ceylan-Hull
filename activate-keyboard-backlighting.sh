#!/bin/sh

usage="Usage: $(basename $0) [-h|--help] [level]: activates the keyboard backlighting; for level 0: 0%, i.e. switched off; for level 1: 50%; for level 2 (the default, if none is specified): 100%."

#echo $usage

if [ ! $(id -u) -eq 0 ]; then

	echo "  Error, you must be root." 1>&2
	exit 5

fi

ctrl_tool=$(which brightnessctl 2>/dev/null)

if [ ! -x "${ctrl_tool}" ]; then

	echo "  Error, 'brightnessctl' tool not available. One may use: 'pacman -Sy brightnessctl'." 1>&2
	exit 10

fi


device_opt=--device='tpacpi::kbd_backlight'

echo "(current brightness level is $(${ctrl_tool} ${device_opt} get))"

level="$1"

if [ "${level}" = "-h" ] ||  [ "${level}" = "--help" ]; then

	echo ${usage}

	exit 0

fi


if [ -z "${level}" ]; then

	level=2

fi

echo "Setting brightness level to ${level}."
${ctrl_tool} ${device_opt} set ${level}

res=$?

if [ $res -eq 0 ]; then

	echo "(success)"

else

	echo "Error, setting failed (code: $res)." 1>&2
	exit 15

fi
