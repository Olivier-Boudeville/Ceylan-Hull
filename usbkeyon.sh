#!/bin/sh

MOUNT_POINT_1=/mnt/usbkey/
MOUNT_POINT_2=/usbkey
MOUNT_POINT_3=/usb1

KEY_FILESYSTEM=vfat

KEY_DEVICE_1=/dev/sda1
KEY_DEVICE_2=/dev/sda2
KEY_DEVICE_3=/dev/sdb1

KEY_DEVICE=${KEY_DEVICE_1}


ACTUAL_MOUNT_POINT=""

MODPROBE=/sbin/modprobe
MOUNT=/bin/mount
LS=/bin/ls
	

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

# Only root can use modprobe :
if [ `id -u` -eq "0" ]; then
	${MODPROBE} usb_storage 1>/dev/null 2>&1 
fi


#${MOUNT} -t ${KEY_FILESYSTEM} ${KEY_DEVICE} ${ACTUAL_MOUNT_POINT} && echo "-- Content of USB key (on ${ACTUAL_MOUNT_POINT}) is :" && ${LS} --color ${ACTUAL_MOUNT_POINT}

# Must be declared in /etc/fstab :
${MOUNT} ${ACTUAL_MOUNT_POINT} && echo "-- Content of USB key (on ${ACTUAL_MOUNT_POINT}) is :" && ${LS} --color ${ACTUAL_MOUNT_POINT}
