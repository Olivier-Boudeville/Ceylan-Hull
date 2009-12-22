#!/bin/sh

# To be preferably declared in root crontab (crontab -e), as from
# /etc/cron.weekly it does not seem to be executed.

# Ex:
# Each Tuesday (2), at 3:17 AM (in the night), update the distro:
# 17 3  * * 2 /root/debian-updater.sh



USAGE="Usage: "`basename $0`": script to be placed in a cron directory (ex: /etc/cron.weekly/), so that the system is regularly 
and automatically updated. Some regular maintenance by hand is to be performed though, in the case some packages require special 
settings, and for dist-upgrade. Ensure you have a local mirror in /etc/apt/sources.list, not to load too much main servers."

# PATH can apparently be garbled by cron:
export PATH=/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin

log_dir="/root/monitoring"

mkdir -p $log_dir

log_file="$log_dir/debian-update-reporter.txt"
/bin/rm -f ${log_file}

apt_opt="-q -y"


date=`LANG= date`

{

	apt-get $apt_opt update && apt-get clean && apt-get $apt_opt upgrade
	res=$?

} 1>$log_file 2>&1


if [ $res -eq 0 ] ; then

	# Success:
	
	touch "$log_dir/debian-update-last-success.timestamp"

	# Log file still there.
	
else

	# Failure:
	
	touch "$log_dir/debian-update-last-failure.timestamp"

	subject="["`hostname`"] System update notification"

	host=`hostname`

	mail_file="$HOME/debian-update-last-error.txt"
	
	echo "System update triggered an error on $host at $date:" > $mail_file

	cat ${log_file} >> $mail_file
	cat ${mail_file} | /usr/bin/mail -s "$subject" debian-update@esperide.com

	# Let the mail_file file exist for any further inspection.
	# Log file still there too.

fi


