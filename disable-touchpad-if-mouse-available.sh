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
# ~/Projects/LOANI-latest/LOANI-repository/ceylan/Ceylan-Hull/disable-touchpad-if-mouse-available.sh

# Two different methods may/have to be used to manage the touchpad.


XINPUT=/bin/xinput

TOUCHPAD_ID=$($XINPUT | grep -i touchpad | cut -f2 | cut -d '=' -f2)

CLIENT=$(which synclient 2>/dev/null)

if $XINPUT | grep -i mouse 1>/dev/null ; then

	#touch ~/TOUCHPAD_DISABLED

	if $XINPUT set-prop $TOUCHPAD_ID "Device Enabled" 0 1>/dev/null ; then

		notify-send "Mouse found, touchpad disabled."
		$CLIENT TouchpadOff=1

	else

		notify-send "Mouse found, yet disabling of touchpad ($TOUCHPAD_ID) failed."
		$CLIENT TouchpadOff=1

		exit 5

	fi

else

	#touch ~/TOUCHPAD_ENABLED

	notify-send "No mouse found, enabling touchpad."
	$XINPUT set-prop $TOUCHPAD_ID "Device Enabled" 1
	$CLIENT TouchpadOff=0

fi
