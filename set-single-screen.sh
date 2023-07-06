#!/bin/sh

usage="Usage: $(basename $0): adapts the displays so that, whether or not an external screen is connected, there is exactly one screen enabled (hence: either the native/internal/main one or an external one; neither both nor none)."

if [ "$1" = "-h" ] || [ "$1" = "--help" ]; then

	echo "${usage}"
	exit

fi

if [ -n "$1" ]; then

	echo "  Error, unexpected parameter(s) specified ('$*').
${usage}"

	exit 5

fi

# Display options listed with: nvidia-settings -q dpys

# Built-in native screen:
#native_screen="DP-3"
native_screen="eDP-1"

# When my Debian-based host is connected to my larger, fixed, LCD external
# screen, it is referenced by:
#
#external_screen="DP-6.1"
#external_screen="DP-6.2"
external_screen="HDMI-1"

# Alternate reference, typically if having plugged-in the computer to another
# screen:
#
# If on the left port:
#alternate_external_screen="DP-3"

# Right port:
alternate_external_screen="DP-6"

xrandr="$(which xrandr 2>/dev/null)"

if [ ! -x "${xrandr}" ]; then

	echo "  Error, no xrandr tool found." 1>&2
	exit 6

fi


# Grepping with a space is necessary, otherwise "DP-6.2" would match "DP-6":
external_screen_status=$("${xrandr}" -q | grep "${external_screen} " | awk '{print $2}')

#echo "external_screen_status = ${external_screen_status}"

if [ "${external_screen_status}" = "disconnected" ]; then

	external_screen="${alternate_external_screen}"

	external_screen_status=$("${xrandr}" -q | grep "${external_screen} " | awk '{print $2}')

	#echo "external_screen_status = ${external_screen_status}"

	if [ "${external_screen_status}" = "disconnected" ]; then

		echo "The external screen is not connected; thus: ensuring that the native screen is enabled."
		if ! ${xrandr} --output ${native_screen} --auto; then
			echo "  Error, failed to enable native screen." 1>&2
			exit 15
		fi

	fi

fi


if [ "${external_screen_status}" = "connected" ]; then

	echo "The external screen is connected; thus: ensuring it is enabled, and disabling the native screen."

	# Order matters:

	if ! ${xrandr} --output ${external_screen} --auto; then
		echo "  Error, failed to enable external screen." 1>&2
		exit 30
	fi

	if ! ${xrandr} --output ${native_screen} --off; then
		echo "  Error, failed to disable native screen." 1>&2
		exit 35
	fi

else

	echo "  Error, unable to detect the status of external screen (got '${external_screen_status}'). Is a dock powered?" 1>&2
	exit 50

fi
