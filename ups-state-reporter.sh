#!/bin/sh

# This script is to be called automatically by nut (upsmon) whenever the state
# of the UPS changes: a mail will then be sent to notify it.

# NUT and ups* must be correctly setup.
# Should be referenced from /etc/nut/upsmon.conf with an enabled daemon.

ups_name="myBelkin"
ups_host="localhost"

ups_notification_address="ups@esperide.com"

# Executed by the nut user, no $HOME available:
TEMP_MAIL="/tmp/.ups-state-reporter.txt"

ups_message="$1"
notification_type="$NOTIFYTYPE"

echo "Notification from the attached UPS:" > ${TEMP_MAIL}

echo "Notification type: $notification_type" >> ${TEMP_MAIL}
echo "Message: $ups_message" >> ${TEMP_MAIL}

echo "
Complete diagnosis follows:" >> ${TEMP_MAIL}

# Does not work: /bin/upsc $ups_name@$ups_host 2>&1 >> ${TEMP_MAIL}
res=`/bin/upsc $ups_name@$ups_host 2>&1`

echo $res >> ${TEMP_MAIL}

subject="["`hostname`"] UPS notification"

cat ${TEMP_MAIL} | /usr/bin/mail -s "$subject" $ups_notification_address

/bin/rm -f ${TEMP_MAIL}
