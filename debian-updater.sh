#!/bin/sh

USAGE="Usage: "`basename $0`": script to be placed in a cron directory (ex : /etc/cron.weekly/), so that the system is regularly and automatically updated. Some regular maintenance by hand is to be performed though, in the case some packages require special settings."


LOG_ROOT=/root/debian-updates

mkdir -p $LOG_ROOT

LOG_FILE=$LOG_ROOT/`date '+%Y%m%d-%Hh%M'`-debian-update.txt

APT_OPT="-q -y"

{

date
apt-get $APT_OPT update 
apt-get $APT_OPT upgrade

} 1>$LOG_FILE 2>&1 

