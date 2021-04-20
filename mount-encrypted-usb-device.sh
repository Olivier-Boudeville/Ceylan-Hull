#!/bin/sh

# Default:
device_name=my-encrypted-device

usage="Usage: $(basename $0) PARTITION_NAME [DEVICE_NAME]
  Mounts specified LUKS-encrypted device (ex: a USB key, or disk), as root (then with specified device name, otherwise with the default one, '${device_name}') or (preferably) as a normal user.
  Example: $(basename $0) /dev/sdb2"


if [ "$1" = "-h" ] || [ "$1" = "--help" ]; then

	echo "${usage}"

	exit 0

fi


if [ $# -ge 3 ]; then

	echo "  Error, too many parameters.
${usage}"

	exit 2

fi


actual_partition="$1"

if [ -z "${actual_partition}" ]; then

	echo "  Error, no partition specified.
${usage}" 1>&2
	exit 5


fi

if [ ! -e "${actual_partition}" ]; then

	echo "  Error, the specified partition '${actual_partition}' does not exist.
${usage}" 1>&2
	exit 10

fi


# Two code paths, depending on being root or not (preferred approach now):

if [ $(id -u) -eq 0 ]; then

	# We are root here:
	# Expected to be already declared in /etc/fstab as well:

	crypt_tool=$(which cryptsetup 2>/dev/null)

	if [ ! -x "${crypt_tool}" ]; then

		echo "  Error, the 'cryptsetup' tool is not available." 1>&2
		exit 15

	fi

	if [ -n "$2" ]; then
		device_name="$2"
	fi

	mount_point=/mnt/${device_name}

	if [ ! -d "${mount_point}" ]; then

		echo "(creating '${mount_point}')"
		mkdir "${mount_point}"

	fi

	${crypt_tool} luksOpen "${actual_partition}" "${device_name}"

	if [ ! $? -eq 0 ]; then

		echo "  Error, the unlocking of the container failed." 1>&2

		exit 20

	fi

	mount /dev/mapper/${device_name} ${mount_point}

	echo "To unmount (still as root): umount ${mount_point} && cryptsetup luksClose ${device_name}"

	# The mount point, if created, would better be deleted afterwards.

else

	# Normal user here, best approach now:

	disk_tool=$(which udisksctl 2>/dev/null)

	if [ ! -x "${disk_tool}" ]; then

		echo "  Error, the 'udisksctl' tool is not available (ex: use 'pacman -Sy udisks2')." 1>&2
		exit 50

	fi

	# Ex: 'Unlocked /dev/sdb2 as /dev/dm-1.' transformed to '/dev/dm-1':
	unencrypted_device=$( ${disk_tool} unlock -b ${actual_partition} | grep Unlocked | sed 's|.*as ||1' | sed 's|\.$||1')


	if [ -z "${unencrypted_device}" ]; then

		echo "  Error, the unlocking of '${actual_partition}' failed (wrong passphrase?)." 1>&2
		exit 55

	fi

	if [ ! -e "${unencrypted_device}" ]; then

		echo "  Error, the unlocking of '${actual_partition}' failed (no device found)." 1>&2
		exit 60

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

	if [ ! $? -eq 0 ]; then

		echo "  Error, mounting '${unencrypted_device}' failed." 1>&2
		exit 65

	else
		echo "To unmount: ${disk_tool} unmount -b ${unencrypted_device} && ${disk_tool} lock -b ${actual_partition}"

	fi

fi
