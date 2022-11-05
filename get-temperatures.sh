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


# Some sensors are almost random generators.

# Removing "(high = +100.0°C, crit = +100.0°C)" or "(crit = +128.0°C)", "ALARM
# sensor = CPU diode", as well as blank lines or non-relevant sensors (negative
# or null temperatures, 127.* °C ones, etc.:
#
# (not relevant enough: grep -E '(°C|Adapter)')
#
"${sensors_cmd}" | grep '°C' | sed 's|(.*)||g' | sed '/^[[:space:]]*$/d' | sed 's|°C.*$|°C|1' | grep -v '+0.0°C' | grep -vE '\-[0-9]*\.[0-9]*°C' | grep -vE '\+127\..*°C'
