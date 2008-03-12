#!/bin/sh

# To run directly from the command-line:
# /usr/sbin/smartctl -a -i /dev/sdc 

TEMP_MAIL="$HOME/.smart-disk-reporter.txt"

# Save the mail body from SMART :
cat > ${TEMP_MAIL}

/usr/sbin/smartctl -a -d $smartd_DEVICETYPE $smartd_DEVICE >> ${TEMP_MAIL}

/usr/bin/mail -s "["`hostname`"] $smartd_SUBJECT" $smartd_ADDRESS < ${TEMP_MAIL}
/bin/rm -f ${TEMP_MAIL}


