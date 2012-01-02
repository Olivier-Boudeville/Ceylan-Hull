#!/bin/sh

# This script is to be called automatically by smartmontools whenever the state
# of a disk changes: a mail will then be sent to notify it.

# SMART must be enabled.
# Should be referenced from /etc/smartd.conf with an enabled daemon.


# More infos:
# http://lea-linux.org/documentations/index.php/Hardware-hard_plus-smart


TEMP_MAIL="$HOME/.smart-disk-reporter.txt"

# Saves the mail body sent by smartmontools:
cat > ${TEMP_MAIL}

echo "To: $SMARTD_ADDRESS" >> ${TEMP_MAIL}
echo "Mailer: $SMARTD_MAILER" >> ${TEMP_MAIL}
echo "Message: $SMARTD_MESSAGE" >> ${TEMP_MAIL}
echo "Device: $SMARTD_DEVICE" >> ${TEMP_MAIL}
echo "Device type: $SMARTD_DEVICETYPE" >> ${TEMP_MAIL}
echo "Device string: $SMARTD_DEVICESTRING" >> ${TEMP_MAIL}
echo "Fail type: $SMARTD_FAILTYPE" >> ${TEMP_MAIL}
echo "Date of first error: $SMARTD_TFIRST" >> ${TEMP_MAIL}
#echo "Number of seconds since 1970: $SMARTD_TFIRSTEPOCH" >> ${TEMP_MAIL}

echo "
Complete diagnosis follows:" >> ${TEMP_MAIL}

# So that "/dev/sdc [SAT]" becomes just ""/dev/sdc":
SHORT_DEVICE=`echo $SMARTD_DEVICE | sed 's| \[.*$||1'`

# To debug:
#echo "Command: /usr/sbin/smartctl -a -d $SMARTD_DEVICETYPE $SHORT_DEVICE" >> ${TEMP_MAIL}

/usr/sbin/smartctl -a -d $SMARTD_DEVICETYPE $SHORT_DEVICE >> ${TEMP_MAIL}

subject="["`hostname`"] $SMARTD_SUBJECT"

cat ${TEMP_MAIL} | /usr/bin/mail -s "$subject" $SMARTD_ADDRESS

/bin/rm -f ${TEMP_MAIL}
