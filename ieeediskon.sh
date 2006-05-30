#!/bin/sh

MOUNT_POINT_1=/mnt/ieeedisk1
MOUNT_POINT_2=/mnt/ieeedisk2
MOUNT_POINT_3=/mnt/ieeedisk3

LS=/bin/ls
MODPROBE=/sbin/modprobe

# Only root can use modprobe :
if [ `id -u` == "0" ]; then
	${MODPROBE} ieee1394
	${MODPROBE} ohci1394
	${MODPROBE} raw1394
	${MODPROBE} sbp2
fi

mount ${MOUNT_POINT_1} && echo "-- Content of IEEE (Firewire) disk, mounted on ${MOUNT_POINT_1} :" && echo && ${LS} --color ${MOUNT_POINT_1}

mount ${MOUNT_POINT_2} && echo "-- Content of IEEE (Firewire) disk, mounted on ${MOUNT_POINT_2} :" && echo && ${LS} --color ${MOUNT_POINT_2}

mount ${MOUNT_POINT_3} && echo "-- Content of IEEE (Firewire) disk, mounted on ${MOUNT_POINT_3} :" && echo && ${LS} --color ${MOUNT_POINT_3} 

