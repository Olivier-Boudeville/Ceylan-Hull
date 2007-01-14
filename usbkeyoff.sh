#!/bin/sh

MOUNT_POINT_1=/mnt/usbkey/
MOUNT_POINT_2=/usbkey
MOUNT_POINT_3=/usb1

ACTUAL_MOUNT_POINT=""

UMOUNT=/bin/umount


# Priority managed (first mount point preferred) :

if [ -d "${MOUNT_POINT_3}" ]; then
	ACTUAL_MOUNT_POINT=${MOUNT_POINT_3}
fi

if [ -d "${MOUNT_POINT_2}" ]; then
	ACTUAL_MOUNT_POINT=${MOUNT_POINT_2}
fi

if [ -d "${MOUNT_POINT_1}" ]; then
	ACTUAL_MOUNT_POINT=${MOUNT_POINT_1}
fi


if [ -z "${ACTUAL_MOUNT_POINT}" ]; then
	echo "No available mount point (tried <${MOUNT_POINT_1}>, <${MOUNT_POINT_2}> and <${MOUNT_POINT_3}>), exiting." 1>&2
	exit 1
fi

if ${UMOUNT} ${ACTUAL_MOUNT_POINT}; then
	echo "<${ACTUAL_MOUNT_POINT}> unmounted, ready to unplug key."
else
	echo "Problem unmounting <${ACTUAL_MOUNT_POINT}>." 1>&2
	exit 2
fi
