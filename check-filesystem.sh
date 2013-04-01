#!/bin/sh


USAGE=`basename $0`": checks for error, and repairs if needed, the specified ext2/ext3/ext4 filesystem."

# One may also run 'smartctl -a /dev/sdX' for example, to check the disk.

if [ ! $# -eq 1 ] ; then

	echo "  Error, one parameter expected." 1>&2
	exit 5

fi

if [ ! `id -u` = "0" ] ; then
	echo "  Error, only root can do that." 1>&2
	exit 10
fi 
	
filesystem=$1

if [ ! -e "$filesystem" ] ; then

	echo "  Error, filesystem '$filesystem' does not exist." 1>&2
	exit 15

fi

tool=`which e2fsck`
	
echo "  Checking filesystem $filesystem..."

$tool -p -f -c -k -D -C0 $filesystem