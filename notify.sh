#!/bin/sh

usage="Usage: $(basename $0) [-h|--help] MESSAGE | TITLE MESSAGE [CATEGORY]: notifies the user about specified message, possibly with a title and a category in 'normal' (the default) | 'process' | 'time' (then with a corresponding icon)."

# Apparently needed on Arch:
# pacman --needed -Sy xfce4-notifyd

# Unit not found for systemctl start xfce4-notifyd.service
# or systemctl --user start xfce4-notifyd.service

# Only working if running (as normal user):
# /usr/lib/xfce4/notifyd/xfce4-notifyd &

# Then, for example:
# notify-send 'Hello world!' 'This is an example notification.' --icon=dialog-information

# Icons described in
# https://specifications.freedesktop.org/icon-naming-spec/latest/ar01s04.html



if [ "$1" = "-h" ] || [ "$1" = "--help" ]; then

	echo "${usage}"
	exit

fi

# Defaults:

# Ex: a light bulb.
default_category="dialog-information"


if [ $# -eq 1 ]; then
	title=""
	message="$1"
	category=""
elif [ $# -eq 2 ]; then
	title="$1"
	message="$2"
	category=""
elif [ $# -eq 3 ]; then
	title="$1"
	message="$2"
	category="$3"

	case "$3" in

		"process")
			# Ex: a kind of gear in a blue background:
			icon="emblem-system"
			;;

		"time")
			# Ex: a clock
			icon="appointment-soon"
			;;

		*)
			icon="${default_icon}"
			;;
	esac
else
	echo "  Error, only one, two or three parameters expected.
$usage" 1>&2
	exit 5
fi

#echo "title=${title}, message=${message}, icon=${icon}"

notify_tool=$(which notify-send 2>/dev/null)

if [ ! -x "${notify_tool}" ]; then

	echo "  Error, notify tool ('notify-send') not found." 1>&2
	exit 10

fi

tts_tool=$(which say.sh 2>/dev/null)

if [ ! -x "${tts_tool}" ]; then

	echo "  Error, text-to-speech tool ('say.sh') not found." 1>&2
	exit 15

fi


# First the sound, if ever the notify-send happened to block....

if [ -z "${icon}" ]; then
	echo "[notification] ${message}"
	${tts_tool} "${message}"
	${notify_tool} "${message}"
else
	echo "[${category}] ${title}: ${message}"
	${tts_tool} "${title}: ${message}"
	${notify_tool} "${title}" "${message}" "--icon=${icon}"
fi
