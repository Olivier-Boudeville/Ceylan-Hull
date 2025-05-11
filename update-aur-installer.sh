#!/bin/sh

usage="Usage: $(basename $0): updates the local AUR (Arch User Repository) installer; to be run as a non-privileged user (i.e. not as root). The 'base-devel' meta package is expected to be already installed."

# Such installers may break after a pacman update (e.g. 'yay: error while
# loading shared libraries: libalpm.so.12: cannot open shared object file: No
# such file or directory'), in which case they should be rebuilt - preferably
# thanks to this script.

# 'yaourt' is no longer recommended (deprecated now), using 'yay' instead.


if [ "$1" = "-h" ] || [ "$1" = "--help" ]; then

	echo "${usage}"

	exit 0

fi



# Allows to avoid creating a /tmp/yay directory possibly owned by root and thus
# not removable by the expected normal user:
#
if [ $(id -u) -eq 0 ]; then

	echo "  Error, this script must be run as a non-privileged user, not as root." 1>&2
	exit 5

fi


git="$(which git 2>/dev/null)"

if [ ! -x "${git}" ]; then

	echo "  Error, no 'git' executable found." 1>&2
	exit 45

fi

echo "  Installing/updating yay AUR installer"


makepkg_opts="--needed --noconfirm"

cd /tmp

if [ -d "yay" ]; then

	/bin/rm -rf yay

fi


# Will fail if base-devel is not installed:
if ! ${git} clone -c init.defaultBranch=master https://aur.archlinux.org/yay.git && cd yay && makepkg ${makepkg_opts} -si && echo && echo "Yay successfully installed/updated!" && cd .. && /bin/rm -rf yay; then

	echo "  Error, installation of yay failed." 1>&2

	exit 15

fi

echo "Now, to install an AUR package, just use, still as a non-privileged user: 'yay -Sy TARGET_PACKAGE' or our 'install-arch-package.sh' script."


# Previously:

# echo "  Updating yaourt AUR installer"

# cd /tmp && ${git} clone https://aur.archlinux.org/package-query.git && cd package-query && makepkg ${makepkg_opts} -si && cd .. && ${git} clone https://aur.archlinux.org/yaourt.git && cd yaourt && makepkg ${makepkg_opts} -si && yaourt -Syua --devel && echo && echo "Yaourt successfully updated!" && cd .. && /bin/rm -rf package-query yaourt
