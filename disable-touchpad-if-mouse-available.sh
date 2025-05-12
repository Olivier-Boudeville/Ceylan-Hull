#!/bin/sh


usage="Usage: $(basename $0) [-h|--help]: ensures that the touchpad (if any) is enabled iff there is no mouse connected.

 Useful if at boot time there is already a mouse connected, as apparently no
 udev event is triggered, thus our toggle-touchpad-enabling.sh script is not
 executed.

 So the current script shall be typically run when the X session is started; so
 typically one may add, before the final exec of one's ~/.xinitrc:

 ${CEYLAN_HULL}/disable-touchpad-if-mouse-available.sh

 Two different methods may/have to be used to manage the touchpad.
"

if [ "$1" = "-h" ] || [ "$1" = "--help" ]; then

	echo "${usage}"
	exit

fi

if [ "$1" ]; then

	echo "  Error, extra parameter specified.
${usage}" 1>&2

	exit 5

fi



# Needed in all cases (even with synclient):
xinput="$(which xinput 2>/dev/null)"

if [ ! -x "${xinput}" ]; then

	echo "  Error, no 'xinput' executable found (Arch package is 'xorg-xinput')." 1>&2
	exit 15

fi


# Which actuator to rely on; synclient not working properly (enabling not
# actually done) at least with Gnome, so:
#
use_synclient=1
use_xinput=0


if [ $use_synclient -eq 0 ]; then

	client="$(which synclient 2>/dev/null)"

	if [ ! -x "${client}" ]; then

		echo "  Error, no 'synclient' executable found." 1>&2
		exit 10

	fi

fi


#touchpad_id=$(${xinput} | grep -i touchpad | cut -f2 | cut -d '=' -f2)
touchpad_id="$(${xinput} --list | grep -i touchpad | sed 's|^.*id=||1' | awk '{print $1}')"
#echo "touchpad_id = ${touchpad_id}"

# Test with a quick workaround as some touchpads may declare themselves also as
# a mouse (e.g. 'ELAN074B:00 04F3:3169 Mouse'):
#
if ${xinput} | grep -v ELAN | grep -i mouse 1>/dev/null; then

	#touch ~/TOUCHPAD_DISABLED

	is_touchpad_enabled="$(${xinput} list-props "${touchpad_id}" | grep 'Device Enabled' | grep -o "[01]$")"
	#echo "is_touchpad_enabled = ${is_touchpad_enabled}"

	if [ "${is_touchpad_enabled}" -eq 1 ]; then

		notify-send "Mouse detected, touchpad enabled, hence disabling it."

		if [ $use_synclient -eq 0 ]; then
			${client} TouchpadOff=0
		fi

		if [ $use_xinput -eq 0 ]; then
			#${xinput} set-prop ${touchpad_id} "Device Enabled" 0
			if ${xinput} --disable ${touchpad_id}; then

				echo "Touchpad disabled."

			else

				echo "  Error, touchpad disabling reported as failed." 1>&2
				exit 58

			fi

		fi

	else

		notify-send "Mouse detected; touchpad was already disabled."

	fi

else

	#touch ~/TOUCHPAD_ENABLED

	notify-send "No mouse found, enabling touchpad."

	if [ $use_synclient -eq 0 ]; then
		${client} TouchpadOff=1
	fi

	if [ $use_xinput -eq 0 ]; then

		#${xinput} set-prop ${touchpad_id} "Device Enabled" 1
		if ${xinput} --enable ${touchpad_id}; then

			echo "Touchpad enabled."

		else

			echo "  Error, touchpad enabling reported as failed." 1>&2
			exit 55

		fi

	fi

fi
