#!/bin/sh

usage="Usage: $(basename $0): monitors endlessly the most CPU-demanding processes. Typically useful to catch an otherwise idle process that uses a full core as soon as the system gets not actively used anymore."

# Firefox, I see you.


monitor_file="monitor-result.txt"

echo
echo "  Monitoring demanding processes (printout also in ${monitor_file})..."
echo "     (hit CTRL-C to stop)"

while true; do

	# For the top-~10 processes (avoiding any 'top' alias):
	( echo ; date; /usr/bin/top -b -n 1 | head -n 17 ) | tee "${monitor_file}"

	sleep 10

done
