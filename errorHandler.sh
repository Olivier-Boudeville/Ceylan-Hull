#!/bin/bash

# Script made to handle error from a log file.

USAGE="$0 <PID> [<error file>]"

echo 

if [ ! $# -le 1 ]; then
	echo "$USAGE"
	exit 1
fi


DEFAULT_ERROR_LOG="error.log"

if [ -z "$2" ]; then
	ERROR_LOG="$PWD/error.log"
else
	ERROR_LOG="$2"
fi

echo "Error handler started with PID $$ and error output $2"

if [ -f "$ERROR_LOG" ]; then
	echo "Deleting previoulsy existing $ERROR_LOG"
	rm $ERROR_LOG
fi

touch $ERROR_LOG


CURRENT_ERROR=`cat $ERROR_LOG`
LAST_ERROR=$CURRENT_ERROR

while [ "true" ]; do
	LAST_ERROR=`cat $ERROR_LOG`
	if [ "$CURRENT_ERROR" != "$LAST_ERROR" ]; then	
		echo -e "\n\t\tError spotted : `tail -1 $ERROR_LOG`\n"
		#sleep 15
		CURRENT_ERROR=`cat $ERROR_LOG`
	fi
done

# Issue a trap if parent PID is dead, to avoid a zombie process.

echo -e "Error handler has finished\n"
