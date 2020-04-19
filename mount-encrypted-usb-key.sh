#!/bin/sh

usage="Mounts specified LUKS-encrypted USB key, as root or as a normal user.
Usage: $(basename $0) PARTITION_NAME
  Example: $(basename $0) /dev/sdb2"

actual_partition="$1"

if [ -z "$actual_partition" ] ; then

	echo "  Error, no partition specified. $usage" 1>&2
	exit 5


fi

if [ ! -e "$actual_partition" ] ; then

	echo "  Error, the specified partition '$actual_partition' does not exist. $usage" 1>&2
	exit 10

fi


# Two code paths, depending on being root or not (preferred approach now):

if [ $(id -u) = "0" ] ; then

	# We are root here:
	# Expected to be already declared in /etc/fstab as well:
	device_name=my-encrypted-usb-key
	mount_point=/mnt/usbstick-encrypted

	cryptsetup luksOpen $actual_partition $device_name
	if [ ! $? -eq 0 ] ; then

		echo "  Error, the unlocking of the container failed." 1>&2

		exit 15

	fi

	mount /dev/mapper/$device_name $mount_point

	echo "To unmount (still as root): umount $mount_point && cryptsetup luksClose $device_name"


else

	# Normal user here, best approach now:

	disk_tool=$(which udisksctl 2>/dev/null)

	if [ ! -x "${disk_tool}" ] ; then

		echo "  Error, the 'udisksctl' tool is not available (use 'pacman -Sy udisks2')." 1>&2
		exit 15

	fi

	# Ex: 'Unlocked /dev/sdb2 as /dev/dm-1.' transformed to '/dev/dm-1':
	unencrypted_device=$( ${disk_tool} unlock -b ${actual_partition} | grep Unlocked | sed 's|.*as ||1' | sed 's|\.$||1')


	if [ -z "${unencrypted_device}" ] ; then

		echo "  Error, the unlocking of '${actual_partition}' failed (wrong passphrase?)." 1>&2
		exit 25

	fi

	if [ ! -e "${unencrypted_device}" ] ; then

		echo "  Error, the unlocking of '${actual_partition}' failed (no device found)." 1>&2
		exit 30

	fi

	${disk_tool} mount -b ${unencrypted_device}

	# May not work, with message: "Error mounting /dev/dm-3:
	# GDBus.Error:org.freedesktop.UDisks2.Error.Failed: Error mounting
	# system-managed device /dev/dm-3: wrong fs type, bad option, bad superblock
	# on /dev/mapper/luks-ab2e31d1-0305-424d-aee3-e16df2d915a0, missing codepage
	# or helper program, or other error."
	#
	# whereas, as root, "mount
	# /dev/mapper/luks-ab2e31d1-0305-424d-aee3-e16df2d915a0 /mnt/tmp" works
	# (also the same with cryptsetup/mount works as root also).

	if [ ! $? -eq 0 ] ; then

		echo "  Error, mounting '${unencrypted_device}' failed." 1>&2
		exit 35

	else
		echo "To unmount: ${disk_tool} unmount -b ${unencrypted_device} && ${disk_tool} lock -b ${actual_partition}"

	fi

fi
