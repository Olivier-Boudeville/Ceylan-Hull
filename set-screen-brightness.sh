#!/bin/sh

help_short_opt="-h"
help_long_opt="--help"


usage="Usage: $(basename $0) [${help_short_opt}|${help_long_opt}] [PERCENTAGE]: sets the screen backlight brightness to the specified percentage level of the maximum brightness.

If no argument is specified, returns the current percentage level.

Note: reading the brightness does not require root permissions, but setting it does.
"

if [ "$1" = "${help_short_opt}" ] || [ "$1" = "${help_long_opt}" ]; then

   echo "${usage}"

   exit

fi


# Solutions (see also https://wiki.archlinux.org/title/Backlight):
#
# - (with XFCE) one may have some luck with Fn-F6 (Sun+, increase brightness)
# and with Fn-F5 (Sun-, decrease brightness)
#
# - xbacklight: only available through the AUR
#
# - xrandr --output eDP-1 --brightness 1.5 (not necessarily as root): only a
# software multiplicate of the current Gamma value


# Applying https://wiki.archlinux.org/title/Backlight#ACPI:

base_dir="/sys/class/backlight"

# For example ${base_dir}/intel_backlight/:
backlight_dir="$(/bin/ls -d -1 ${base_dir}/* | head --lines=1)"
#echo "backlight_dir = ${backlight_dir}"

if [ ! -d "${backlight_dir}" ]; then

	echo "  Error, no backlight interface found in '${base_dir}'." 1>&2

	exit 20

fi

#echo "Found backlight interface '${backlight_dir}'."

raw_max_value="$(cat ${backlight_dir}/max_brightness)"
#echo "raw_max_value = ${raw_max_value}"

raw_current_value="$(cat ${backlight_dir}/actual_brightness)"
#echo "raw_current_value = ${raw_current_value}"

# Order matters:
current_value="$(expr ${raw_current_value} \* 100 \/ ${raw_max_value})"


if [ -z "$1" ]; then

	echo "Current backlight level: ${current_value}%"

	exit

fi

# Setting here, thus must be root:
if [ ! $(id -u) -eq 0 ]; then

	echo "  Error, setting brightness requires root permissions." 1>&2
	exit 5

fi

target_value="$1"

echo "Setting backlight level to ${target_value}% (while being at ${current_value}%)"

# Order matters as well:
target_raw_value="$(expr ${target_value} \* ${raw_max_value} \/ 100)"
#echo "target_raw_value = ${target_raw_value}"


# Pipe added to avoid any noclobber:
echo "${target_raw_value}" >| "${backlight_dir}/brightness"

raw_current_value="$(cat ${backlight_dir}/actual_brightness)"
current_value="$(expr ${raw_current_value} \* 100 \/ ${raw_max_value})"

echo "(succesfully set to ${current_value}%)"
