#!/bin/sh

usage="Usage: $(basename $0): updates the mirror list for the current GNU/Linux distribution"

# Only Arch supported currently.

conf_path="/etc/pacman.d/mirrorlist"

echo "Updating Arch mirrors in ${conf_path}..."


backup_conf_path="${conf_path}-$(date '+%Y%m%d')"


# Expected to exist:
if [ -f "${conf_path}" ]; then

	# Overwrites any prior one:
	/bin/mv -f "${conf_path}" "${backup_conf_path}"

fi


# Directly adapted from https://wiki.archlinux.org/title/Mirrors:
if curl -s "https://archlinux.org/mirrorlist/?country=FR&country=GB&countryt=DE&protocol=https&use_mirror_status=on" | sed -e 's/^#Server/Server/' -e '/^#/d' | rankmirrors -n 10 - >  "${conf_path}"; then

	echo "Mirrors updated; result is:"
	cat "${conf_path}"

	exit 0

else

	echo "Mirror update failed." 1>&2

	if [ -f "${backup_conf_path}" ]; then

		/bin/mv -f "${backup_conf_path}" "${conf_path}"

		echo "Mirrors restored to:" 1>&2
		cat "${conf_path}" 1>&2

	fi

	exit 5

fi
