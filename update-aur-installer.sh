#!/bin/sh


echo "  Updating yay AUR installer"

# Yaourt is no longer recommended (depracted now), use for example 'yay'
# instead!

makepkg_opts="--needed --noconfirm"


cd /tmp && git clone https://aur.archlinux.org/yay.git && cd yay && makepkg ${makepkg_opts} -si && echo && echo "Yay successfully updated!" && cd .. && rm -rf yay


# echo "  Updating yaourt AUR installer"

# cd /tmp && git clone https://aur.archlinux.org/package-query.git && cd package-query && makepkg ${makepkg_opts} -si && cd .. && git clone https://aur.archlinux.org/yaourt.git && cd yaourt && makepkg ${makepkg_opts} -si && yaourt -Syua --devel && echo && echo "Yaourt successfully updated!" && cd .. && rm -rf package-query yaourt
