#!/bin/sh

# Tired of typing it:

# Default is Debian:
distro_type="Debian"

# Not used anymore, cause often redefined:
#if cat /etc/issue | grep Arch 1>/dev/null 2>&1 ; then

distro_id_file="/etc/os-release"

if [ -f "$distro_id_file" ] ; then

	source "$distro_id_file"

	if [ "$NAME" = "Arch Linux" ] ; then

		distro_type="Arch"

	fi

fi

#echo "Distro type: $distro_type"


if [ `id -u` -eq 0 ] ; then

	echo "Updating the distribution now..."

	case "${distro_type}" in

		"Debian")
			apt-get update && apt-get -y upgrade
			;;

		"Arch")
			pacman -Syu --noconfirm
			;;

		*)
			echo "Unsupported distribution: ${distro_type}" 1>&2
			exit 10
			;;

	esac

	echo "...done"

else

	echo "You must be root to update your distribution!" 1>&2
	exit 5

fi
