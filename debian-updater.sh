#!/bin/sh

USAGE="Usage: "`basename $0`": script to be placed in a cron directory (ex: /etc/cron.weekly/), so that the system is regularly and automatically updated. Some regular maintenance by hand is to be performed though, in the case some packages require special settings, and for dist-upgrade. Ensure you have a local mirror in /etc/apt/sources.list, not to load too much main servers"


log_file="$HOME/.debian-update-reporter.txt"

apt_opt="-q -y"

date=`LANG= date`

{

apt-get $apt_opt update && apt-get $apt_opt upgrade
res=$?

} 1>$log_file 2>&1 


if [ ! $res -eq 0 ] ; then

	subject="["`hostname`"] System update notification"

	host=`hostname`

	mail_file="$HOME/debian-update-last-error.txt"
	echo "System update triggered an error on $host at $date:" > $mail_file

	
	cat ${log_file} >> $mail_file
	cat ${mail_file} | /usr/bin/mail -s "$subject" debian-update@esperide.com

	# Let the mail_file file exist for any further inspection.

fi

# Let the log_file file to know the date and content of latest update:
#/bin/rm -f ${log_file}

