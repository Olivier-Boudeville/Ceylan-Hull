#!/bin/sh

# Previously was fixed, but a mounted directory cannot be reused; then suffixes
# could be added, but it was not convenient, so now using unique, generated
# directory names:
#
#mount_point="/tmp/my-mtp-device"

mounter_name="aft-mtp-mount"

usage="Usage: $(basename $0) [MOUNT_POINT]: mount any plugged, non-locked MTP device (e.g. a smartphone, an Android e-reader) to any specified mount point, otherwise to a uniquely-generated one (recommended, as more stable).

Executing this script is likely to trigger an authorization request on the device.

If encountering errors like 'Transport endpoint is not connected', 'no MTP device found' or 'Device is already used by another process', then a new mount shall be performed (first by unplugging/plugging again the USB cable).

Note that:
- device content may appear on the local filesystem only after a few seconds after this script was executed
- a file generated on the device after the mounting is likely not to be visible from the mount point

Using '${mounter_name}' for that (the approach that we recommend); alternatively one may rely on 'aft-mtp-cli' to have a shell of the MTP device's pseudo-filesystem, or 'android-file-transfer' to have a very simple GUI.
"


if [ "$1" = "-h" ] || [ "$1" = "--help" ]; then

	echo "${usage}"

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

	# Any content does not seem to appear immediately:
	sleep 1

	dir_count="$(/bin/ls -1 ${mount_point} | wc -l)"

	if [ "${dir_count}" = "1" ]; then

		target_dir="$(ls -1 ${mount_point})"

	else

		target_dir="${mount_point}"

	fi

	echo "MTP device mounted on '${target_dir}'. Enjoy!"

	# No real unmounting seems available...

fi
