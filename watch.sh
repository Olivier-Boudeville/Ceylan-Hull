#!/bin/sh

usage="Usage: $(basename $0) <expression to watch in running processes>.\nExample: $(basename $0) AP2 to track all processes which have AP2 in their command or arguments."


if [ -z "$1" ] ; then

	echo -e "\nError, no expression to watch.\n\t$usage."

	exit 5

fi


watch_file="watch-result.txt"

#local_user="$USER"
local_user=$(whoami)

#echo "search expression: $1"
#echo "user: $local_user"
#echo "script: $(basename $0)"

# Default: %CPU, %MEM and short command:
show_full_cmd=1

if [ $show_full_cmd -eq 0 ] ; then

	ps_opt="-o comm,args"

else

	ps_opt="-o pcpu,pmem,args"

fi


# To display the relevant header once, first:

ps -ed ${ps_opt} | head --lines=1


stop=1

while [ $stop -eq 1 ] ; do

	# Useful to show the user that not stuck:
	echo "   Watching $1..."

	ps -ed ${ps_opt} | grep "$local_user" | grep -v $(basename $0) | grep -v grep | grep -i "$1"

	echo
	sleep 1

done 2>&1 | tee ${watch_file}
