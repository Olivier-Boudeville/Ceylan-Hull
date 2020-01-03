#!/bin/sh

if [ ! $(id -u) -eq 0 ]; then

	echo " Error, this script must be run as root." 1>&2
	exit 5

fi

echo "  Inspecting TCP/UDP ports currently opened:"

lsof -i

# Also: netstat -lptu
