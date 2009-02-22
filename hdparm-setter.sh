#!/bin/sh

# Actually the setting cannot be performed reliably by script.
# One just has to determine once the correct settings and specify them
# one time for all in /etc/hdparm.conf

# Procedure:

# hdarm_opt="-d1 -c1 -A1 -u1 -a64"
# use 'hdparm -i /dev/hdX |grep MaxMultSect' to know the number N of sector
# count.
# If MaxMultSect=16, then hdarm_opt="$hdarm_opt -m 16"


# Script was:

cd /proc

if [ -d ide ] ; then
	cd ide
	ide_drives=`/bin/ls -d hd* 2>/dev/null`
	cd ..
fi

# Disabled: apparently hdparm cannot tune SATA or SCSI drives:
# (look at sdparm?)
#if [ -d scsi ] ; then
#	cd scsi
#	scsi_drives=`/bin/ls -d s* 2>/dev/null`
#	cd ..
#fi


eligible_drives="$ide_drives $scsi_drives"

echo "Eligible found drives: $eligible_drives"

# List the drives you want tuned here:
selected_drives=""


if [ -z "$selected_drives" ] ; then
	echo "No drive selected."
	exit
fi

hdparm="/sbin/hdparm"

if [ ! -x "$hdparm" ] ; then
	echo "Error, hdparm tool not available." 1>&2
	exit 10
fi

echo "Settings hdparm best-performance parameters for following drives: $selected_drives"

# -d1: activates DMA (reliable)
# -c1: activates 32-bit mode (reliable)
# -A1: activates read-lookahead (quite reliable)
# -mN: sector count for multiple sector I/O on the drive; see
# hdparm -i /dev/hdX |grep MaxMultSect to know the number of sector count N
# -u1: permits the driver to unmask other interrupts during processing of 
# a disk interrupt, which greatly improves Linuxs responsiveness and 
# eliminates "serial port overrun" errors (use with caution)
# -aN: sector count for filesystem (software) read-ahead. This is used to 
# improve performance in sequential reads of large files; choose a value N
# equal to max(current,64) (reliable)
# -W1: IDE/SATA drives write-caching feature (UNreliable)
hdarm_opt="-d1 -c1 -A1 -m16 -u1 -a64 -W1"

# Diagnosis: -d -c -A -m -u -a -W

for d in $selected_drives; do
	$hdparm $hdarm_opt $d
done 

