#!/bin/sh


USAGE="
Usage: $(basename $0) PARTITION_NAME
  Example: $(basename $0) /dev/sdb2"

ACTUAL_PARTITION="$1"

if [ -z "$ACTUAL_PARTITION" ] ; then

	echo "  Error, no partition specified. $USAGE" 1>&2
	exit 5


fi

if [ ! -e "$ACTUAL_PARTITION" ] ; then

	echo "  Error, the specified partition '$ACTUAL_PARTITION' does not exist. $USAGE" 1>&2
	exit 10

fi


# Two code paths, depending on being root or not (preferred approach now):

if [ $(id -u) = "0" ] ; then

	# We are root here:
	# Expected to be already declared in /etc/fstab as well:
	DEVICE_NAME=my-encrypted-usb-key
	MOUNT_POINT=/mnt/usbstick-encrypted

	cryptsetup luksOpen $ACTUAL_PARTITION $DEVICE_NAME
	if [ ! $? -eq 0 ] ; then

		echo "  Error, the unlocking of the contained failed." 1>&2

		exit 15

	fi

	mount /dev/mapper/$DEVICE_NAME $MOUNT_POINT

	echo "To unmount (still as root): umount $MOUNT_POINT && cryptsetup luksClose $DEVICE_NAME"


else

	# Normal user here, best approach now:

	DISK_TOOL=$(which udisksctl 2>/dev/null)

	if [ ! -x "${DISK_TOOL}" ] ; then

		echo "  Error, the 'udisksctl' tool is not available (use 'pacman -Sy udisks2')." 1>&2
		exit 15

	fi

	# Ex: 'Unlocked /dev/sdb2 as /dev/dm-1.' transformed to '/dev/dm-1':
	UNENCRYPTED_DEVICE=$( ${DISK_TOOL} unlock -b ${ACTUAL_PARTITION} | grep Unlocked | sed 's|.*as ||1' | sed 's|\.$||1')


	if [ -z "${UNENCRYPTED_DEVICE}" ] ; then

		echo "  Error, the unlocking of '${ACTUAL_PARTITION}' failed (wrong passphrase?)." 1>&2
		exit 25

	fi

	if [ ! -e "${UNENCRYPTED_DEVICE}" ] ; then

		echo "  Error, the unlocking of '${ACTUAL_PARTITION}' failed (no device found)." 1>&2
		exit 30

	fi

	${DISK_TOOL} mount -b ${UNENCRYPTED_DEVICE}

	if [ ! $? -eq 0 ] ; then

		echo "  Error, mounting '${UNENCRYPTED_DEVICE}' failed." 1>&2
		exit 35

	else
		echo "To unmount: ${DISK_TOOL} unmount -b ${UNENCRYPTED_DEVICE} && ${DISK_TOOL} lock -b ${ACTUAL_PARTITION}"

	fi

fi
