#!/bin/sh

usage="Usage: $(basename $0) [--silent]: adapts the displays so that, whether or not an external screen is connected, there is exactly one screen enabled (hence: either the native/internal/main one or an external one; neither both nor none).

Returns (as echo), possibly for a caller script, either 'on_internal_screen' or 'on_external_screen'.
"

if [ "$1" = "-h" ] || [ "$1" = "--help" ]; then

	echo "${usage}"
	exit

fi


is_verbose=0

if [ "$1" = "--silent" ]; then

	is_verbose=1
	shift

fi


if [ -n "$1" ]; then

	echo "  Error, unexpected parameter(s) specified ('$*').
${usage}"

	exit 5

fi

# Display options listed with: nvidia-settings -q dpys


# Defaults:

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


res="on_internal_screen"


# Grepping with a space is necessary, otherwise "DP-6.2" would match "DP-6":
external_screen_status=$("${xrandr}" -q | grep "${external_screen} " | awk '{print $2}')

# echo "external_screen_status = ${external_screen_status}"

if [ "${external_screen_status}" = "disconnected" ]; then

	external_screen="${alternate_external_screen}"

	external_screen_status=$("${xrandr}" -q | grep "${external_screen} " | awk '{print $2}')

	#echo "external_screen_status = ${external_screen_status}"

	if [ "${external_screen_status}" = "disconnected" ]; then

		[ $is_verbose -eq 0 ] && echo "The external screen is not connected; thus: ensuring that the native screen is enabled."

		if ! "${xrandr}" --output ${native_screen} --auto; then
			echo "  Error, failed to enable the native screen (${native_screen})set-sin." 1>&2
			exit 15
		fi

	fi

fi


if [ "${external_screen_status}" = "connected" ]; then

	[ $is_verbose -eq 0 ] && echo "The external screen (${external_screen}) is connected; thus: ensuring it is enabled, and disabling the native screen (${native_screen})."
	res="on_external_screen"

	# Order matters:

	# Disabled, as may reconduct a lower logical resolution (e.g. after a
	# clone):
	#
	#if ! "${xrandr}" --output "${external_screen}" --auto; then
	#	echo "  Error, failed to enable external screen." 1>&2
	#	exit 30
	#fi

	external_best_res=$("${xrandr}" --query | sed "1,/${external_screen}/d" | grep '*' | head -n 1 | awk '{print $1}' | sed 's|\+.*||1')

	[ $is_verbose -eq 0 ] && echo "Detected best resolution for external screen: '${external_best_res}'."

	#echo Executing: "${xrandr}" --output "${external_screen}" --mode "${external_best_res}"

	# Setting scale is needed, otherwise a previous, generally lower, logical
	# resolution could be reused:
	#
	if ! "${xrandr}" --output "${external_screen}" --mode "${external_best_res}" --scale 1x1; then
		echo "  Error, failed to enable and set external screen (${external_screen}) to '${external_best_res}'." 1>&2
		exit 30
	fi

	if ! "${xrandr}" --output "${native_screen}" --off; then
		echo "  Error, failed to disable native screen (${native_screen})." 1>&2
		exit 35
	fi

else

	[ $is_verbose -eq 0 ] && echo "Unable to detect the status of external screen ${external_screen} (got '${external_screen_status}'). Is a dock powered and the cable correctly plugged-in? Supposing no." #1>&2

	# Not an error anymore:
	#exit 50

fi

echo "${res}"
