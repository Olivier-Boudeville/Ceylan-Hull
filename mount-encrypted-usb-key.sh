#!/bin/sh

if [ ! $(id -u) = "0" ] ; then

	echo "  Error, this script must be run as root." 1>&2

	exit 5

fi


# Expected to be already declared in /etc/fstab as well:
DEVICE_NAME=my-encrypted-usb-key
MOUNT_POINT=/mnt/usbstick-encrypted

ACTUAL_PARTITION=/dev/sdb2


cryptsetup luksOpen $ACTUAL_PARTITION $DEVICE_NAME
if [ ! $? -eq 0 ] ; then

	echo "  Error, the unlocking of the contained failed." 1>&2

	exit 10

fi

mount /dev/mapper/$DEVICE_NAME $MOUNT_POINT

echo "To unmount, as root: umount $MOUNT_POINT && cryptsetup luksClose $DEVICE_NAME"
