#!/bin/sh

usage="Usage: $(basename $0): reports the status of the specified RAID disk (script for automation)."

# This script is to be called automatically by mdadm whenever the state of a
# RAID array changes: a mail will then be sent to notify it.

# Software RAID must be enabled.
# Should be referenced from /etc/mdadm/mdadm.conf.


# More infos: http://man-wiki.net/index.php/5:mdadm.conf

raid_address="raid@esperide.com"


event="$1"
md_device="$2"

# If any:
component_device="$3"


tmp_mail="${HOME}/.raid-disk-reporter.txt"

echo "Message from RAID array monitor:" > ${tmp_mail}

echo "Event: ${event}" >> ${tmp_mail}
echo "MD device: ${md_device}" >> ${tmp_mail}

if [ -n "${component_device}" ]; then
	echo "Component device: ${component_device}" >> ${tmp_mail}
fi

echo "
Complete diagnosis follows:" >> ${tmp_mail}
/sbin/mdadm --detail ${md_device} 2>&1 >> ${tmp_mail}

subject="[$(hostname -f)] RAID notification"

/bin/cat ${tmp_mail} | /usr/bin/mail -s "${subject}" "${raid_address}"

/bin/rm -f ${tmp_mail}
