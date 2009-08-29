#!/bin/sh

XRANDR=/usr/bin/xrandr


CURRENT_RES=`${XRANDR} | grep '*' | awk '{print $1}'`

# External LCD (instead of 1440x900):
TARGET_RES="1680x1050"

# Laptop LCD:
#TARGET_RES="1280x800"


#echo "Current resolution is ${CURRENT_RES}"

if [ "${CURRENT_RES}" != "${TARGET_RES}" ] ; then

	echo "Switching to ${TARGET_RES}..."
	${XRANDR} --size ${TARGET_RES}
	echo "...done"

else
	echo "(nothing done, already at target resolution ${TARGET_RES})"
fi

