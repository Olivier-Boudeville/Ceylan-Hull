#!/bin/sh

echo "  Updating yaourt AUR installer"

makepkg_opts="--needed --noconfirm"

cd /tmp && git clone https://aur.archlinux.org/package-query.git && cd package-query && makepkg ${makepkg_opts} -si && cd .. && git clone https://aur.archlinux.org/yaourt.git && cd yaourt && makepkg ${makepkg_opts} -si && echo && echo "Yaourt successfully updated!" && cd .. && rm -rf package-query yaourt
