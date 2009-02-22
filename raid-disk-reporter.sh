#!/bin/sh

# This script is to be called automatically by mdadm whenever the 
# state of a RAID array changes: a mail will then be sent to notify it.

# Software RAID must be enabled.
# Should be referenced from /etc/mdadm/mdadm.conf.


# More infos: http://man-wiki.net/index.php/5:mdadm.conf

RAID_ADDRESS="raid@esperide.com"


event="$1"
md_device="$2"

# If any:
component_device="$3"


TEMP_MAIL="$HOME/.raid-disk-reporter.txt"

echo "Message from RAID array monitor:" > ${TEMP_MAIL}

echo "Event: $event" >> ${TEMP_MAIL}
echo "MD device: $md_device" >> ${TEMP_MAIL}

if [ -n "$component_device" ] ; then
	echo "Component device: $component_device" >> ${TEMP_MAIL}
fi

echo "
Complete diagnosis follows:" >> ${TEMP_MAIL}
/sbin/mdadm --detail $md_device 2>&1 >> ${TEMP_MAIL}

subject="["`hostname`"] RAID notification"

cat ${TEMP_MAIL} | /usr/bin/mail -s "$subject" $RAID_ADDRESS

/bin/rm -f ${TEMP_MAIL}

