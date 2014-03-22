#!/bin/sh

if [ ! `id -u` = "0" ] ; then
	echo "Error, only root can do that."
	exit
fi

TARGET_FILE=system-settings-of-$(hostname -s).txt


echo "  Recording system settings in file '$TARGET_FILE'..."

unset LANG

echo -e "\n\nThese are the system settings of $(hostname -f) as they were on $(date '+%A, %B %-e, %Y') at $(date '+%H:%M:%S').\n" > ${TARGET_FILE}


exec_cmd()
{

	cmd="$1"

	echo -e "\n\n **** executing '${cmd}'" >> ${TARGET_FILE}

	${cmd} >> ${TARGET_FILE}

	if [ ! $? -eq 0 ] ; then

		echo "  Error, command '${cmd}' failed." 1>&2
		exit 50

	fi

}

exec_cmd "hostname -f"

exec_cmd "cat /etc/os-release"

exec_cmd "lspci"

exec_cmd "cat /proc/cpuinfo"

exec_cmd "lsmod"

exec_cmd "cat /etc/crypttab"

exec_cmd "cat /etc/fstab"

exec_cmd "lsblk -af"

exec_cmd "fdisk -l"

exec_cmd "lsusb"

exec_cmd "df -h"

exec_cmd "ls -l /dev/mapper/*"

exec_cmd "free --human --total"

exec_cmd "uname -a"

exec_cmd "cat /etc/netctl/*network*"

exec_cmd "ip addr"

exec_cmd "swapon -s"

# List installed packages:
exec_cmd "pacman -Qqe"
