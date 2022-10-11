#!/bin/sh

# Ensures that the touchpad (if any) is enabled iff there is no mouse connected.
#
# Useful if at boot time there is already a mouse connected, as apparently no
# udev event is triggered, thus our toggle-touchpad-enabling.sh script is not
# executed.
#
# So the current script shall be typically run when the X session is started; so
# typically one may add, before the final exec of one's ~/.xinitrc:
#
# $CEYLAN_HULL/disable-touchpad-if-mouse-available.sh

# Two different methods may/have to be used to manage the touchpad.


xinput=$(which xinput 2>/dev/null)

if [ ! -x "${xinput}" ]; then

	echo "  Error, no 'xinput' executable found." 1>&2
	exit 5

fi


client=$(which synclient 2>/dev/null)

if [ ! -x "${synclient}" ]; then

	echo "  Error, no 'synclient' executable found." 1>&2
	exit 10

fi


touchpad_id=$(${xinput} | grep -i touchpad | cut -f2 | cut -d '=' -f2)


if ${xinput} | grep -i mouse 1>/dev/null; then

	#touch ~/TOUCHPAD_DISABLED

	if ${xinput} set-prop ${touchpad_id} "Device Enabled" 0 1>/dev/null; then

		notify-send "Mouse found, touchpad disabled."
		${client} TouchpadOff=1

	else

		notify-send "Mouse found, yet disabling of touchpad ($touchpad_id) failed."
		${client} TouchpadOff=1

		exit 5

	fi

else

	#touch ~/TOUCHPAD_ENABLED

	notify-send "No mouse found, enabling touchpad."
	${xinput} set-prop ${touchpad_id} "Device Enabled" 1
	${client} TouchpadOff=0

fi
