#!/bin/sh

usage="Usage: $(basename $0) [-h|--help] [-r|--reboot]: shutdowns (otherwise, with the option: reboots) the current, local host just after having performed any relevant, automated system update.
  -r or --reboot: reboots instead of shutting down"


if [ ! "$(id -u)" -eq 0 ]; then

	echo "  Error, this script must be run as root." 1>&2
	exit 5

fi


if [ "$1" = "-h" ] || [ "$1" = "--help" ]; then

	echo "${usage}"

	exit 0

fi


# Otherwise reboots:
halt=0

if [ "$1" = "-r" ] || [ "$1" = "--reboot" ]; then

	halt=1
	shift

fi


if [ -n "$1" ]; then

	echo "  Error, extra parameter specified.
${usage}" 1>&2

	exit 15

fi


if [ $halt -eq 0 ]; then

	echo "

System will shutdown now host **$(hostname -s)** (check it is the expected one!), after a possible update (including notably its kernel, possibly some other drivers)...
"

else

	echo "

System will reboot now host **$(hostname -s)** (check it is the expected one!), after a possible update (including notably its kernel, possibly some other drivers)...
"

fi

read -p "  Press the Enter key to continue (CTRL-C to abort)" value


echo " - performing first a general system update"

if ! pacman --noconfirm -Syu; then

	echo "  Error, general update failed." 1>&2
	exit 5

fi

# As we shutdown, updating the kernel is not a problem regarding modules that
# are yet loaded:
#
# (overrides any IgnorePkg directive in /etc/pacman.conf)
#
echo " - performing then any kernel (with headers) update"

if ! pacman --noconfirm --needed -Sy linux linux-headers; then

	echo "  Error, kernel update failed." 1>&2
	exit 10

fi


# Note:
#
# - no linux-lts upgraded here intentionally, to avoid having both kernels
# too close and potentially suffering from the same problems
#
# - on computer having a graphical card, after the kernel update the graphic
# drivers should better be reinstalled; either this is done automatically -
# through dkms (not always working properly, apparently), or it can be done
# explicitly, with for example: 'pacman -Su nvidia nvidia-utils nvidia-lts'.
#
# Refer to https://wiki.archlinux.org/title/NVIDIA#Installation.

# Not used anymore, as modules may fail to load and then would not be updated;
#if lsmod 2>/dev/null | grep nvidia; then

	# Output example:
	#
	# nvidia_drm             73728  2
	# nvidia_modeset       1155072  3 nvidia_drm
	# nvidia              36954112  84 nvidia_modeset
	# drm_kms_helper        303104  1 nvidia_drm
	# drm                   589824  6 drm_kms_helper,nvidia,nvidia_drm

# More relevant:
if lspci 2>/dev/null | grep NVIDIA 1>/dev/null; then

	# Output example:
	#
	# 01:00.0 VGA compatible controller: NVIDIA Corporation GP106 [GeForce GTX
	# 1060 6GB] (rev a1)
	# 01:00.1 Audio device: NVIDIA Corporation GP106 High Definition Audio
	# Controller (rev a1)

	echo "The use of a NVidia device has been detected, forcing a corresponding upgrade in turn of its drivers (after the kernel)."

	# Not '--needed', we want to force the matching with any newly installed
	# kernel (the whole process is fragile enough):
	#
	if ! pacman --noconfirm -Sy nvidia nvidia-utils; then

		echo "  Error, NVidia update failed." 1>&2
		exit 15

	fi

fi

# A bit of sleep to be able to read:
if [ $halt -eq 0 ]; then

	echo "Stopping now for good."
	sleep 1
	shutdown --poweroff now

else

	echo "Rebooting now."
	sleep 1
	# Better than 'reboot':
	shutdown --reboot now

fi


# Not expected to be ever seen:
echo "Stopped."
