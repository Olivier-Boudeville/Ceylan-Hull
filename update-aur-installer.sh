#!/bin/sh

usage="Usage: $(basename $0): updates the local AUR (Arch User Repository) installer; to be run as a non-priviledged user (i.e. not as root)."

# Such installers may break after a pacman update (e.g. 'yay: error while
# loading shared libraries: libalpm.so.12: cannot open shared object file: No
# such file or directory'), in which case they should be rebuilt - preferably
# thanks to this script.


# 'yaourt' is no longer recommended (deprecated now), using 'yay' instead.

# Allows to avoid creating a /tmp/yay directory possibly owned by root and thus
# not removable by the expected normal user:
#
if [ $(id -u) -eq 0 ]; then

	echo "  Error, this script must be run as a non-priviledged user, not as root." 1>&2
	exit 5

fi


echo "  Updating yay AUR installer"


makepkg_opts="--needed --noconfirm"

cd /tmp

if [ -d "yay" ]; then

	/bin/rm -rf yay

fi

git clone https://aur.archlinux.org/yay.git && cd yay && makepkg ${makepkg_opts} -si && echo && echo "Yay successfully updated!" && cd .. && /bin/rm -rf yay

echo "Now, to install an AUR package, just use, still as a non-priviledged user: 'yay -Sy TARGET_PACKAGE'."


# Previously:

# echo "  Updating yaourt AUR installer"

# cd /tmp && git clone https://aur.archlinux.org/package-query.git && cd package-query && makepkg ${makepkg_opts} -si && cd .. && git clone https://aur.archlinux.org/yaourt.git && cd yaourt && makepkg ${makepkg_opts} -si && yaourt -Syua --devel && echo && echo "Yaourt successfully updated!" && cd .. && /bin/rm -rf package-query yaourt
