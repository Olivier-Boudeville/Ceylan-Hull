#!/bin/sh

usage="Usage: $(basename $0) [-h|--help] PACKAGE_NAME: installs a package on Arch Linux, found as either a standard Arch one (with pacman), or as an AUR package; any needed prior installation or update of an AUR installer is managed automatically.

To be run preferably as a non-privileged user (sudo used whenever necessary)."

# See also update-aur-installer.sh and update-distro.sh.

# Apparently yay could take care of AUR packages but also of standard Arch Linux
# packages.

if [ "$1" = "-h" ] || [ "$1" = "--help" ]; then

	echo "${usage}"

	exit 0

fi

if [ $(id -u) -eq 0 ]; then

	echo "Warning: this script should probably not be run as root." 1>&2

fi

pacman="$(which pacman 2>/dev/null)"

if [ ! -x "${pacman}" ]; then

	echo "  Error, no 'pacman' executable found." 1>&2

	exit 10

fi

aur_updater_name="update-aur-installer.sh"

# A single one supported (easier than $*):
package_name="$1"

echo "  Looking up package '${package_name}'..."

if "${pacman}" -Ss "^${package_name}$" 1>/dev/null 2>&1; then

	echo "Found as an Arch Linux official package, installing it if needed."
	sudo "${pacman}" -S "${package_name}" --needed --noconfirm

else

	echo "(not found as a standard Arch Linux package, trying the AUR)"

	yay="$(which yay 2>/dev/null)"

	if [ ! -x "${yay}" ]; then

		echo "No AUR installer ('yay') found, installing it first."

		# Expected to be found as well in Ceylan-Hull, or at least in the PATH:
		aur_updater="$(which ${aur_updater_name} 2>/dev/null)"

		if [ ! -x "${aur_updater}" ]; then

			echo "  Error, no AUR updater ('${aur_updater_name}') found." 1>&2

			exit 40

		fi

		# Not to be run as root:
		if ! "${aur_updater}"; then

			echo "  Error, AUR update (done by '${aur_updater_name}') failed." 1>&2
			exit 45

		fi

		yay="$(which yay 2>/dev/null)"

		if [ ! -x "${yay}" ]; then

			echo "  Error, no post-install yay found." 1>&2
			exit 35

		fi

	else

		# Installer found, but is it functional? (often broken by a
		# pacman-related update)

		if ! "${yay}" -h 1>/dev/null 2>&1; then

			echo "  AUR installer ('yay') found, yet not operational, updating it first."

			# Expected to be found as well in Ceylan-Hull:
			aur_updater="$(which ${aur_updater_name} 2>/dev/null)"

			if [ ! -x "${aur_updater}" ]; then

				echo "  Error, no AUR updater ('${aur_updater_name}') for yay found." 1>&2

				exit 50

			fi

			# Not to be run as root:
			if ! "${aur_updater}"; then

				echo "  Error, AUR update (done by '${aur_updater_name}') for yay failed." 1>&2
				exit 55

			fi

		fi

		if ! "${yay}" -h 1>/dev/null 2>&1; then

			echo "  AUR installer ('yay') still not operational, failing." 1>&2

			exit 70

		fi

	fi

	# yay expected to be available and functional from here.

	# Will request root privileges:
	if ! "${yay}" -S "${package_name}" --needed --noconfirm; then

		echo "  Installation failed; if the error is in link with gpg/dirmngr, consider executing 'killall gpg-agent dirmngr' or fixing any ~/.gnupg/dirmngr.conf, and retrying this install." 1>&2

	fi

fi
