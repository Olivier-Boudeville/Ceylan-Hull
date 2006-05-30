#!/bin/bash

USAGE="Usage : `basename $0` <expression to watch in running processes>.\nExample : `basename $0` AP2 to track all processes which have AP2 in their command or arguments."

if [ -z "$1" ] ; then
	echo -e "\nError, no expression to watch.\n\t$USAGE."
	exit 1
fi	

WATCH_FILE="watch-result.txt"

#LOCAL_USER="$USER"
LOCAL_USER=`whoami`

PS_CMD="ps -edf | grep $LOCAL_USER"
#PS_CMD="ps -ed -o comm"

#echo "search expression : $1"
#echo "user : $LOCAL_USER"
#echo "script : "`basename $0`

show_full_cmd="true"

stop=1

while [ "$stop" == 1 ] ; do

	echo "   Watching $1..."
	
	if [ ${show_full_cmd} == "true" ]; then
	
		# Full command :
		ps -ed -o comm,args | grep -v `basename $0` | grep -v grep | grep -i "$1"
	else
	
		# Command filtered by user :
		ps -edf | grep "$LOCAL_USER" | grep -v `basename $0` | grep -v grep | grep -i "$1"
	fi
	
	echo
	sleep 1
	
done 2>&1 | tee ${WATCH_FILE}


