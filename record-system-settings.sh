#!/bin/sh

host_id="$(hostname -f)"

# To avoid // if run from /:
target_file="$(realpath $(pwd)/$(date '+%Y%m%d')-system-settings-of-${host_id}.txt)"

usage="Usage: $(basename $0): records in file ${target_file} the main system settings of the local host ($(hostname -s))."



if [ ! $# -eq 0 ]; then

	echo "${usage}"

	exit 0

fi


if [ ! $(id -u) -eq 0 ]; then

	echo "  Error, only root can do that." 1>&2
	exit 5

fi



echo "  Recording system settings of host ${host_id} in file '${target_file}'..."

unset LANG

echo -e "\n\nThese are the system settings of host $(host_id) as they were on $(date '+%A, %B %-e, %Y') at $(date '+%H:%M:%S').\n" > ${target_file}


exec_cmd()
{

	cmd="$1"

	echo -e "\n\n **** executing '${cmd}'" >> ${target_file}

	${cmd} >> ${target_file}

	if [ ! $? -eq 0 ]; then

		echo "  Error, command '${cmd}' failed." 1>&2
		exit 50

	fi

}



# Basics:

exec_cmd "hostname -f"

exec_cmd "cat /etc/os-release"



# Hardware:

exec_cmd "cat /proc/cpuinfo"

exec_cmd "dmidecode"

exec_cmd "lshw"

exec_cmd "lspci"

exec_cmd "lsusb"



# System:

exec_cmd "uname -a"

exec_cmd "lsmod"

exec_cmd "swapon -s"

exec_cmd "systemctl status"

exec_cmd "uptime"

# List installed packages:
exec_cmd "pacman -Qqe"



# Devices:

exec_cmd "cat /etc/crypttab"

exec_cmd "cat /etc/fstab"

exec_cmd "lsblk -af"

exec_cmd "fdisk -l"

exec_cmd "mount"

exec_cmd "df -h"

exec_cmd "ls -l /dev/mapper/*"

exec_cmd "free --human --total"



# Network:

exec_cmd "ip addr"

exec_cmd "ip link"

for f in /etc/netctl/* ; do if [ -f "$f" ]; then echo "\n\n **** listing content of file '$f': "; cat "$f" ; fi ; done >> ${target_file}

exec_cmd "iptables -nL"

echo -e "\n\nEnd of system report." >> ${target_file}
