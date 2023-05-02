#!/bin/sh

usage="Usage: $(basename $0): adapts the displays so that, whether or not an external screen is connected, there is exactly one screen enabled (hence: either the laptop one or the external one; neither both nor none)."

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

# Built-in laptop screen:
#laptop_screen="DP-3"
laptop_screen="eDP-1"

# When my Scibian 9 is connected to my larger, fixed, LCD desktop screen, it is
# referenced by:
#
#desktop_screen="DP-6.1"
#desktop_screen="DP-6.2"
desktop_screen="HDMI-1"

# Alternate reference, typically if having plugged-in the computer to another
# screen:
#
# If on the left port:
#alternate_desktop_screen="DP-3"

# Right port:
alternate_desktop_screen="DP-6"

xrandr="$(which xrandr 2>/dev/null)"

if [ ! -x "${xrandr}" ]; then

	echo "  Error, no xrandr tool found." 1>&2
	exit 6

fi


# Grepping with a space is necessary, otherwise "DP-6.2" would match "DP-6":
desktop_screen_status=$("${xrandr}" -q | grep "${desktop_screen} " | awk '{print $2}')

#echo "desktop_screen_status = ${desktop_screen_status}"

if [ "${desktop_screen_status}" = "disconnected" ]; then

	desktop_screen="${alternate_desktop_screen}"

	desktop_screen_status=$("${xrandr}" -q | grep "${desktop_screen} " | awk '{print $2}')

	#echo "desktop_screen_status = ${desktop_screen_status}"

	if [ "${desktop_screen_status}" = "disconnected" ]; then

		echo "The desktop screen is not connected; thus: ensuring that the laptop screen is enabled."
		if ! ${xrandr} --output ${laptop_screen} --auto; then
			echo "  Error, failed to enable laptop screen." 1>&2
			exit 15
		fi

	fi

fi


if [ "${desktop_screen_status}" = "connected" ]; then

	echo "The desktop screen is connected; thus: ensuring it is enabled, and disabling the laptop screen."

	# Order matters:

	if ! ${xrandr} --output ${desktop_screen} --auto; then
		echo "  Error, failed to enable desktop screen." 1>&2
		exit 30
	fi

	if ! ${xrandr} --output ${laptop_screen} --off; then
		echo "  Error, failed to disable laptop screen." 1>&2
		exit 35
	fi

else

	echo "  Error, unable to detect the status of desktop screen (got '${desktop_screen_status}'). Is a dock powered?" 1>&2
	exit 50

fi
