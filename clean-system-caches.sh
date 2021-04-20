#!/bin/sh

if [ $(id -u) -eq 0 ]; then
	echo " Cleaning system caches: full removal of the content of pacman cache..."
	pacman -Scc --noconfirm 1>/dev/null && echo "  ... success!"
else
	echo "Error, you must be root." 1>&2
	exit 5
fi
