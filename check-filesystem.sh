#!/bin/sh

usage="Usage: $(basename $0): checks for errors, and repairs if needed, the specified  filesystem."

# Only ext2/ext3/ext4.

# One may also run 'smartctl -a /dev/sdX' for example, to check the disk.

if [ ! $# -eq 1 ]; then

	echo "  Error, one parameter expected." 1>&2
	exit 5

fi

if [ ! $(id -u) = "0" ]; then
	echo "  Error, only root can do that." 1>&2
	exit 10
fi

filesystem="$1"

if [ ! -e "${filesystem}" ]; then

	echo "  Error, filesystem '$filesystem' does not exist." 1>&2
	exit 15

fi


check_tool=$(which e2fsck 2>/dev/null)

if [ ! -x "${check_tool}" ]; then

	echo "   Error, checking tool found." 1>&2

	exit 20

fi

echo "  Checking filesystem ${filesystem}..."

${check_tool} -p -f -c -k -D -C0 ${filesystem}
