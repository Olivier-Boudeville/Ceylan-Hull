#!/bin/sh

# This script is made to be executed in a fresh installation of Debian 3.0, with settings chosen
# according to Installation-setpByStep.txt, on aranor.

# It will configure it according to my will.

# Author : Olivier Boudeville (olivier.boudeville@online.fr)
# Created : 2003, June, 21

if [ `id -ru ` != "0" ] ; then
	echo "This script must be executed by root"
	exit
fi

echo "Copying the correct files in correct places"
./installBaseFiles.sh

echo "Updating the boot sequence"
./updateBootSequence.sh


echo "Preparing some directories"

mkdir -p /mnt/hdb1
mkdir -p /mnt/hdb2
mkdir -p /mnt/hdb3
mkdir -p /mnt/hdb4

mkdir -p /usr/man/man1
mkdir -p /root/tmp

echo "recompile a new kernel, /sbin/lilo -v"

echo "/sbin/reboot"

