#!/bin/sh


usage="Usage: $(basename $0): returns a list of the temperatures known of the system, for various components (cores, disks, motherboard, etc.)
"

if [ $# -ge 1 ]; then

	echo "  Error, extra parameters specified.
${usage}" 1>&2
	exit 20

fi


sensors_cmd=$(which sensors 2>/dev/null)

if [ ! -x "${sensors_cmd}" ]; then

	echo "  Error, no 'sensors' tool available." 1>&2

	exit 10

fi

# Removing "(high = +100.0°C, crit = +100.0°C)" or "(crit = +128.0°C)", as well
# as blank lines or non-relevant sensors:
#
# (not relevant enough: grep -E '(°C|Adapter)')
#
"${sensors_cmd}" | grep '°C' | sed 's|(.*)||g' | sed '/^[[:space:]]*$/d' | grep -v '+0.0°C'
