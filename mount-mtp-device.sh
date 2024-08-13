#!/bin/sh

# Previously was fixed, but a mounted directory cannot be reused; then suffixes
# could be added, but it was not convenient, so now using unique, generated
# directory names:
#
#mount_point="/tmp/my-mtp-device"

mounter_name="aft-mtp-mount"

usage="Usage: $(basename $0) [MOUNT_POINT]: mount any plugged, non-locked MTP device (e.g. a smartphone, an Android e-reader) to any specified mount point, otherwise to a uniquely-generated one (recommended, as more stable).

If encountering errors like 'Transport endpoint is not connected', then a new mount shall be performed.

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

	# For a Bookean Notéa, one could jump to:
	# "Internal shared storage"
	# "Espace de stockage interne partagé"

	echo "MTP device mounted on '${mount_point}'. Enjoy!"

	# No real unmounting seems available...

fi
