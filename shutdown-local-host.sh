#!/bin/sh

usage="$(basename $0): shutdowns current, local host after having performed any relevant system update."


if [ ! $(id -u) -eq 0 ]; then

	echo "  Error, this script must be run as root." 1>&2
	exit 5

fi


echo "

System will shutdown now host $(hostname -s), after a possible update (including notably its kernel)...
"

read -e -p "  Press Enter key to continue (CTRL-C to abort)" value


echo " - performing first a general system update"
pacman --noconfirm -Sy

if [ ! $? -eq 0 ]; then

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

if [ ! $? -eq 0 ]; then

	echo "  Error, kernel update failed." 1>&2
	exit 10

fi

echo "Stopping now for good."
shutdown -h now

# Not expected to be seen:
echo "Stopped."
