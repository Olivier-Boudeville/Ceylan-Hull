#!/bin/sh

usage="Usage: $(basename $0) [-h|--help] [-w]: forces a specified video resolution.

Options:
 -h or --help: this help
 -w: applies settings for running on windowed mode
"

if [ "$1" = "-h" ] || [ "$1" = "--help" ]; then

	echo "${usage}"

	exit 0

fi


xrandr=/usr/bin/xrandr


current_res=$(${xrandr} | grep '*' | awk '{print $1}')

# External LCD (instead of 1440x900):
# target_res="1680x1050"

# Older laptop LCD:
#target_res="1280x800"

# Other laptop LCD (more recent):
target_res="1920x1080"

if [ "$1" = "-w" ]; then

	# Other laptop LCD (more recent), emulated in windowed mode:
	target_res="1600x900"

fi


#echo "Current resolution is ${current_res}"

if [ "${current_res}" != "${target_res}" ]; then

	echo "Switching to ${target_res}..."
	${xrandr} --size ${target_res}
	echo "...done"

else

	echo "(nothing done, already at target resolution ${target_res})"

fi
