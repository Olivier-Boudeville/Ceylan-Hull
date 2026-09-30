#!/bin/sh

# Copyright (C) 2006-2026 Olivier Boudeville
#
# Author: Olivier Boudeville [olivier (dot) boudeville (at) esperide (dot) com]
#
# This file is part of the Ceylan-Hull toolbox (see http://hull.esperide.org).


usage="Usage: $(basename $0) <expression to watch in running processes>.\nExample: $(basename $0) AP2 to track all processes that include "AP2" in their command or arguments."

expr="$1"

if [ -z "${expr}" ]; then

	echo  "Error, no expression to watch specified.
${usage}" 1>&2

	exit 5

fi


watch_file="watched-processes-result.txt"

#local_user="$USER"
local_user="$(whoami)"

#echo "search expression: ${expr}"
#echo "user: ${local_user}"
#echo "script: $(basename $0)"

# Default: %CPU, %MEM and short command:
show_full_cmd=1

if [ $show_full_cmd -eq 0 ]; then

	ps_opt="-o comm,args"

else

	ps_opt="-o pcpu,pmem,args"

fi

period_secs=1

echo
echo "  Starting the watch for '${expr}' (show full command: $show_full_cmd)"
echo "     (period: ${period_secs} seconds; hit CTRL-C to stop)"
echo

# To display the relevant header once, first:
ps -ed ${ps_opt} | head --lines=1


while true; do

	# Useful to show the user that is not stuck:
	echo "   Watching processes matching '${expr}'..."

	ps -ed ${ps_opt} | grep "${local_user}" | grep -v $(basename $0) | grep -v grep | grep -i "${expr}"

	echo
	sleep ${period_secs}

done 2>&1 | tee "${watch_file}"
