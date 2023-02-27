#!/bin/sh

usage="Usage: $(basename $0) [-h|--help]: displays the status of the local batteries, using the most relevant tool available (including depending on user permissions)."

if [ "$1" = "-h" ] | [ "$1" = "--help" ]; then

	echo "${usage}"
	exit

fi


# Preferred, as most precise, but specialised for Thinkpads and requiring root:
tlp_stat_tool_name="tlp-stat"

# Safe fallback:
upower_tool_name="upower"


if [ ! $(id -u) -eq 0 ]; then

	# Not root here:

	upower="$(which ${upower_tool_name} 2>/dev/null)"

	if [ -x "${upower}" ]; then

		echo
		echo "    Displaying battery status with ${upower_tool_name} (not being root):"
		echo

		for b in $(${upower} -e | grep 'BAT'); do

			echo " - for battery '$b':
$(${upower} -i $b)"
			echo

		done

		exit

	else

		echo "  Error: not running as root, and no ${upower_tool_name} tool available." 1>&2
		exit 5

	fi

fi


# Being root here:

tlp_stat="$(which ${tlp_stat_tool_name} 2>/dev/null)"

if [ -x "${tlp_stat}" ]; then

	echo
	echo "  Displaying battery status with ${tlp_stat_tool_name} (as root):"
	echo

	${tlp_stat} -b

else

	echo "(no relevant battery-related tool found, neither ${tlp_stat_tool_name} nor ${upower_tool_name})" 1>&2
	exit 10

fi
