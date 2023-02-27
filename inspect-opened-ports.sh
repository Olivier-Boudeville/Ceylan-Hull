#!/bin/sh

usage="Usage: $(basename $0): lists the local TCP/UDP ports that are currently opened."

if [ ! $(id -u) -eq 0 ]; then

	echo " Error, this script must be run as root." 1>&2
	exit 5

fi

echo "  Inspecting TCP/UDP ports currently opened:"


# To display raw IP/ports (convenient to grep), use:
# lsof -i -nP

# Most user-friendly view:
lsof -i

# Also: netstat -lptu
