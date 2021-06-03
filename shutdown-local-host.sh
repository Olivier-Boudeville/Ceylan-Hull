#!/bin/sh

usage="$(basename $0): shutdowns current, local host after having performed any relevant system update."


if [ ! "$(id -u)" -eq 0 ]; then

	echo "  Error, this script must be run as root." 1>&2
	exit 5

fi


echo "

System will shutdown now host $(hostname -s), after a possible update (including notably its kernel)...
"

read -p "  Press Enter key to continue (CTRL-C to abort)" value


echo " - performing first a general system update"
pacman --noconfirm -Sy

if ! pacman --noconfirm -Sy; then

	echo "  Error, general update failed." 1>&2
	exit 5

fi

# As we shutdown, updating the kernel is not a problem regarding modules that
# are yet loaded:
#
# (overrides any IgnorePkg directive in /etc/pacman.conf)
#
echo " - performing then any kernel (with headers) update"
pacman --noconfirm --needed -Sy linux linux-headers

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
# through dkms, or it can be done explicitly, with for example:
#       pacman -Su nvidia nvidia-utils nvidia-lts
# Refer to https://wiki.archlinux.org/title/NVIDIA#Installation.


echo "Stopping now for good."
shutdown -h now

# Not expected to be seen:
echo "Stopped."
