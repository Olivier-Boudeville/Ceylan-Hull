#!/bin/sh

usage="Usage: $(basename $0): diagnoses whether the various network basic facilities are functional."

#gateway_ip=192.168.0.10
gateway_ip=10.0.0.1

gateway_name="${GATEWAY}"

if [ -z "${gateway_name}" ]; then
	gateway_name=sonata
fi

#reliable_internet_server_ip=72.14.207.99
#reliable_internet_server_ip=66.249.92.104

# Corresponds to google.com
reliable_internet_server_ip=8.8.8.8

reliable_internet_server_name=google.com


echo "Checking current network status..."

if ping -c 2 ${gateway_ip} 1>/dev/null 2>&1; then

	echo "Gateway IP (${gateway_ip}) responding, internal network connectivy ok."
	if ping -c 2 ${gateway_name} 1>/dev/null 2>&1; then

		echo "Gateway DNS name (${gateway_name}) responding, internal DNS ok."

		if ping -c 2 ${reliable_internet_server_ip} 1>/dev/null 2>&1; then

			echo "Reliable internet server IP (${reliable_internet_server_ip}) responding, external network connectivy ok."

			if ping -c 2 ${reliable_internet_server_name} 1>/dev/null 2>&1; then

				echo "Reliable internet server DNS name (${reliable_internet_server_name}) responding, external DNS ok."

				echo "Everything seems to be fine!"

			else

				echo "Reliable internet server DNS name (${reliable_internet_server_name}) not responding, external DNS ko?"
				exit 4

			fi

		else

			echo "Reliable internet server IP (${reliable_internet_server_ip}) not responding, external network connectivy ko?"
			exit 3

		fi

	else

		echo "Gateway DNS name (${gateway_name}) not responding, internal DNS ko?"
		exit 2
	fi

else

	echo "Gateway IP (${gateway_ip}) not responding, internal network connectivity ko?"
	echo "Pinging now continuously to know when network is back..."

	ping ${gateway_ip}

	exit 1

fi
