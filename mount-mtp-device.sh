#!/bin/sh

# Previously was fixed, but a mounted directory cannot be reused; then suffixes
# could be added, but it was not convenient, so now using unique, generated
# directory names:
#
#mount_point="/tmp/my-mtp-device"

mounter_name="aft-mtp-mount"

mount_prefix="/tmp/ceylan-hull-mount-mtp-device-"


usage="Usage: $(basename $0) [-h|--help] [-uma|--umount-all] [MOUNT_POINT]: mount any USB-plugged, active, non-locked MTP device (e.g. a smartphone, an Android e-reader) to any specified mount point, otherwise to a uniquely-generated one (in the form of'${mount_prefix}*') - which is recommended, as more stable.

The -uma/--umount-all option stands for \"umount all\":then the script will attempt to umount all points (based on the default naming) it may have mounted previously.

Executing this script is likely to trigger an authorization request on the device.


Note that:
- if the mount point is found empty, probably that the device is waiting for the sharing to be acknowledged by the user; when authorised, the mount point will be populated
- device content may appear on the local filesystem only after a few seconds after this script was executed
- a file generated on the device after the mounting is likely not to be visible from the mount point

If encountering errors like 'Transport endpoint is not connected', 'no MTP device found' or 'Device is already used by another process', then a new mount shall be performed (first by unplugging/plugging again the USB cable).

Using '${mounter_name}' for that (the approach that we recommend); alternatively one may rely on 'aft-mtp-cli' to have a shell of the MTP device's pseudo-filesystem, or 'android-file-transfer' to have a very simple GUI.
"


if [ "$1" = "-h" ] || [ "$1" = "--help" ]; then

	echo "${usage}"

	exit

fi


if [ "$1" = "-uma" ] || [ "$1" = "--umount-all" ]; then

	points="$(/bin/ls -1 -d ${mount_prefix}* 2>/dev/null)"

	echo "Unmounting (lazily) all previous points:"

	for p in ${points}; do

		# Lazily found more efficient than regular or even forced:
		echo " - umounting '$p'"
		umount -l $p 2>/dev/null && rmdir $p 2>/dev/null

	done

	echo "Unmounting done."

	exit

fi



if [ -n "$1" ]; then

	mount_point="$1"

	if [ ! -d "${mount_point}" ]; then

		#echo "(creating user-specified directory '{mount_point}')"
		mkdir -p "${mount_point}"

	fi

	shift

fi



if [ ! $# -eq 0 ]; then

	echo "  Error, extra parameters specified ('$*')." 1>&2

	exit 5

fi



mounter="$(which ${mounter_name} 2>/dev/null)"

if [ ! -x "${mounter}" ]; then

	echo "  Error, no mounting program found (no '${mounter_name}')." 1>&2

	exit 10

fi


if [ -z "${mount_point}" ]; then

	mount_point="$(mktemp --directory /tmp/ceylan-hull-mount-mtp-device-XXXX)"

	#echo "(using generated directory '${mount_point}')"

fi

#echo "Using mount point '${mount_point}'."


if ! "${mounter}" "${mount_point}"; then

	echo "  Error, mount failed." 1>&2

	exit 25

else

	# Quite often there is a single directory at the root, which could thus be
	# jumped to:

	# For a Bookean Notéa, one could jump to:
	# "Internal shared storage"
	# "Espace de stockage interne partagé"
	#
	# For some (Android, French) smartphones: 'Stockage interne', etc.

	# Not a good idea, ridden with spaces, hence not useful:

	# Any content does not seem to appear immediately:
	#sleep 1

	#dir_count="$(/bin/ls -1 ${mount_point} | wc -l)"

	#if [ "${dir_count}" = "1" ]; then

	#   target_dir="$(ls -1 ${mount_point})"

	#else

	#   target_dir="${mount_point}"

	#fi

	#echo "MTP device mounted on '$(realpath ${target_dir})'. Enjoy!"

	echo "MTP device mounted on '${mount_point}'. Enjoy!"

	echo "(use the -uma/--umount-all option to unmount easily afterwards)"

fi
