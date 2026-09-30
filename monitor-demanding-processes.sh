#!/bin/sh

# Copyright (C) 2021-2026 Olivier Boudeville
#
# Author: Olivier Boudeville [olivier (dot) boudeville (at) esperide (dot) com]
#
# This file is part of the Ceylan-Hull toolbox (see http://hull.esperide.org).


usage="Usage: $(basename $0): monitors endlessly the most CPU-demanding processes. Typically useful to catch an otherwise idle process that uses a full core as soon as the system gets not actively used anymore."

# Firefox, I see you.

period_secs=4

monitor_file="monitored-demanding-processes.txt"

echo
echo "  Monitoring demanding processes (printout also in ${monitor_file})..."
echo "     (period: ${period_secs} seconds; hit CTRL-C to stop)"

while true; do

	# For the top-~10 processes (avoiding any 'top' alias):
	( echo ; date; /usr/bin/top -b -n 1 | head -n 17 ) | tee "${monitor_file}"

	sleep ${period_secs}

done
