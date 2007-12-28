#!/bin/sh

XRANDR=/usr/bin/xrandr

# If 1440x900, set 1680x1050:

CURRENT_RES=`${XRANDR} | grep '*' | awk '{print $1}'`

TARGET_RES="1680x1050"

#echo "Current resolution is ${CURRENT_RES}"

if [ "${CURRENT_RES}" = "1440x900" ] ; then
	echo "Switching to ${TARGET_RES}..."
	${XRANDR} --size ${TARGET_RES}
	echo "...done"
else
	echo "(nothing done, already at target resolution ${TARGET_RES})"
fi
