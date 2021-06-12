#!/bin/sh

usage="Usage: $(basename $0): updates the mirror list for the current GNU/Linux distribution"


# Directly adapted from https://wiki.archlinux.org/title/Mirrors:
curl -s "https://archlinux.org/mirrorlist/?country=FR&country=GB&countryt=DE&protocol=https&use_mirror_status=on" | sed -e 's/^#Server/Server/' -e '/^#/d' | rankmirrors -n 10 -