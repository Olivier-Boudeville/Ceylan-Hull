#!/bin/sh

# Copyright (C) 2026-2026 Olivier Boudeville
#
# Author: Olivier Boudeville [olivier (dot) boudeville (at) esperide (dot) com]
#
# This file is part of the Ceylan-Hull toolbox (see http://hull.esperide.org).


usage="Usage: $(basename $0): monitors endlessly the (local) BEAM processes, each being taken as a whole (with its various threads aggregated)."

period_secs=1

monitor_file="monitored-beam-processes.txt"

echo
echo "  Monitoring all local BEAM processes (printout also in ${monitor_file})..."
echo "     (period, in seconds: ${period_secs}; hit CTRL-C to stop)"
echo

node_name_width=48
cpu_width=5
rss_width=6
pid_width=8

print_lines()
{

	char="$1"
	printf "%${node_name_width}s" | tr ' ' "${char}"
	printf " "
	printf "%${cpu_width}s" | tr ' ' "${char}"
	printf " "
	printf "%${rss_width}s" | tr ' ' "${char}"
	printf " "
	printf "%${pid_width}s" | tr ' ' "${char}"
	printf "\n"

}

print_lines "="

# Side-effect: resets that file.
(printf "%-${node_name_width}s %${cpu_width}s %6s %8s\n" "Node name" "CPU%" "RSS" "PID") | tee "${monitor_file}"

print_lines "="
echo

while true; do

	#node_name_width=0

	# Not wanting to select the /tmp/erlang_serviceXXXX wrappers:
	#ps -C beam.smp -o pid=,%cpu=,rss=,cmd= |
	#ps -p $(pgrep -x beam.smp | paste -sd,) -o pid=,%cpu=,rss=,cmd= |

	for pid in $(pgrep -x beam.smp); do

		cmd=$(ps -p $pid -o cmd=)
		case "$cmd" in
			/tmp/erlang_service*) continue ;;
		esac

		cpu=$(ps -p $pid -o %cpu=)
		rss=$(ps -p $pid -o rss=)

		printf "%s %s %s %s\n" "$pid" "$cpu" "$rss" "$cmd"

	done |

		while read pid cpu rss cmd; do
			#echo "Read: pid=$pid cpu=$cpu rss=$rss cmd=$cmd"

			rss_str=$(echo "${rss}" | awk '
{
    if ($1 < 1024)          printf "%dK\n", $1;
    else if ($1 < 1024^2)   printf "%.1fM\n", $1/1024;
    else                    printf "%.1fG\n", $1/1024/1024;
}')
			# Extract the second capture, the word after -sname or -name:
			node_name=$(echo "${cmd}" | sed 's/.*-\(sname\|name\)[[:space:]]\+\([^[:space:]]\+\).*/\2/')

			# Auto-sizing not satisfactory:

			#echo "Node name: '${node_name}'."
			#node_len=$(expr length "${node_name}'")
			#
			#if [ ${node_name_width} -lt ${node_len} ]; then
			#
			#	node_name_width=${node_len}
			#
			#fi

			#echo " VM ${node_name} (PID:${pid}): CPU=${cpu}%, RSS=${rss_str}"
			(printf "%-${node_name_width}s %${cpu_width}s %6s %8s\n" "$node_name" "$cpu%" "$rss_str" "$pid") | tee -a "${monitor_file}"
		done

	print_lines "-"
	(echo) | tee -a "${monitor_file}"
	sleep ${period_secs}

done
