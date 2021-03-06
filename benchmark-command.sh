#!/bin/sh

# Copyright (C) 2010-2021 Olivier Boudeville
#
# Author: Olivier Boudeville [olivier (dot) boudeville (at) esperide (dot) com]
#
# This file is part of the Ceylan-Hull library.


usage="Usage: $(basename $0) [-h|--help] COMMAND: returns a mean resource consumption for the specifiedshell command."

if [ "$1" = "-h" ] || [ "$1" = "--help" ]; then

	echo "  ${usage}"
	exit

fi

command="$*"

if [ -z "${command}" ]; then

	echo "  Error, no command specified.
  ${usage}" 1>&2
	exit 5

fi

#/usr/bin/time --format "Wall-clock time, in [hours:]minutes:second: %E\nTotal number of CPU-seconds used by the system on behalf of the process (in kernel mode), in seconds.Average total (data+stack+text) memory use of the process, in Kilobytes: %K" ${command}

#/usr/bin/time -f "Wallclock time: %E seconds\nUser time: %Us\nSystem time: %Ss\nMemory: %K KB" ${command} 1>/dev/null

echo "Starting timer"

/usr/bin/time -f "Wallclock time: %E seconds\nUser time: %Us\nSystem time: %Ss" ${command} 1>/dev/null
