#!/bin/sh

usage="Usage: $(basename $0): diagnoses whether the various network basic facilities are functional. If not, check them continously, until all of them are back to normal."

if [ "$1" = "-h" ] || [ "$1" = "--help" ]; then

	echo "${usage}"

	exit

fi


if [ ! $# -eq 0 ]; then

	echo "  Error, no argument is expected.
${usage}" 1>&2

	exit 25

fi


gateway_name="${GATEWAY}"

if [ -z "${gateway_name}" ]; then

	echo "  Error, no gateway name set (GATEWAY environment variable)." 1>&2
	exit 15

fi

#gateway_ip=192.168.0.10
#gateway_ip=10.0.0.1
gateway_ip="$(host ${gateway_name} | sed 's|.*address ||1')"

#reliable_internet_server_ip=72.14.207.99
#reliable_internet_server_ip=66.249.92.104

# Corresponds to google.com
reliable_internet_server_ip=8.8.8.8

reliable_internet_server_name=google.com

is_good=1

while [ $is_good -eq 1 ]; do

	echo
	echo "Checking current network status at $(date)..."

	if ping -c 2 ${gateway_ip} 1>/dev/null 2>&1; then

		echo " - gateway IP (${gateway_ip}) responding, internal network connectivy ok"
		if ping -c 2 ${gateway_name} 1>/dev/null 2>&1; then

			echo " - gateway DNS name (${gateway_name}) responding, internal DNS ok"

			if ping -c 2 ${reliable_internet_server_ip} 1>/dev/null 2>&1; then

				echo " - reliable internet server IP (${reliable_internet_server_ip}) responding, external network connectivy ok"

				if ping -c 2 ${reliable_internet_server_name} 1>/dev/null 2>&1; then

					echo " - reliable internet server DNS name (${reliable_internet_server_name}) responding, external DNS ok"

					echo "Everything seems to be fine!"
					is_good=0

				else

					echo "Reliable internet server DNS name (${reliable_internet_server_name}) not responding, external DNS ko?" 1>&2
					#exit 4

				fi

			else

				echo "Reliable internet server IP (${reliable_internet_server_ip}) not responding, external network connectivy ko?" 1>&2
				#exit 3

			fi

		else

			echo "Gateway DNS name (${gateway_name}) not responding, internal DNS ko?" 1>&2
			#exit 2

		fi

	else

		echo "Gateway IP (${gateway_ip}) not responding, internal network connectivity ko?" 1>&2

		#echo "Pinging now continuously to know when network is back..."
		#ping ${gateway_ip}

		#exit 1

		sleep 2

	fi

done
