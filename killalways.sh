#!/bin/bash

USAGE="$0 <process name to kill> [--autoKill]: while this script is running, it will track down and destroy any process matching the supplied name"

TARGET="$1"
shift

do_debug="false"
do_autokill="false"

echo 

if [ -z "$TARGET" ]; then
	echo -e "$USAGE\n\nError, no target process specified."
	exit 1
fi


[ "$do_debug" == "false" ] || echo "DEBUG: TARGET is $TARGET"

if [ "$1" == "--autoKill" ]; then
	shift
	echo "### Warning: will automatically kill any process matching $TARGET (without further notice) ###"
	echo
	do_autokill="true"
fi

EDITOR_TO_LET_ALIVE="nedit"

echo -e  "\tWill kill, from now on, any process matching $TARGET..."

do_stop=0

while [ $do_stop -eq 0 ]; do

	TO_KILL_NAMES=""
	
	while [ -z "$TO_KILL_NAMES" ]; do
		TO_KILL_NAMES=`ps -u \`whoami\` -o args | grep "$TARGET" | grep -v grep | grep -v "$EDITOR " | grep -v "vi " | grep -v \`basename $0\` | grep -v "nedit "`
		sleep 1
	done
	
	if [ "$do_autokill" == "true" ]; then
		choice="y"
	else	
        	echo "Following processes will be killed:"
		ps -u `whoami` -o args | grep "$TARGET" | grep -v grep | grep -v "$EDITOR " | grep -v "vi " | grep -v `basename $0` | grep -v "$EDITOR_TO_LET_ALIVE"
        
        	read -e -p "Should we kill them ? (y/n) [n]: " choice
	fi
		
        if [ "$choice" == "y" ]; then
                FIRST=`ps -u $(whoami) -o pid,args | grep "$TARGET" | grep -v grep |  grep -v "$EDITOR " | grep -v "vi " | grep -v $(basename $0) | grep -v "nedit " | awk '{print $1}'`
		
                if [ -n "$FIRST" ]; then
			[ "$do_debug" == "false" ] || echo "DEBUG: PID is $FIRST"
                        kill $FIRST
                fi
		
        	SECOND=`ps -u $(whoami) -o pid,args | grep "$TARGET" | grep -v grep |  grep -v "$EDITOR " | grep -v "vi " | grep -v $(basename $0) | grep -v "nedit " | awk '{print $1}'`
                if [ -n "$SECOND" ]; then
			[ "$do_debug" == "false" ] || echo "DEBUG: PID is $SECOND"		
                        kill -9 $SECOND
                fi
		
		if [ $? -eq 0 ]; then
			echo "$TO_KILL_NAMES killed !"		
		else
			echo "Error while killing $TO_KILL_NAMES"
		fi

        else
                echo "Killed cancelled"
        fi

done
