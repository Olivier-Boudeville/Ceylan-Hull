#!/bin/sh

GATEWAY_IP=192.168.0.3
GATEWAY_NAME=aranor

RELIABLE_INTERNET_SERVER_IP=72.14.207.99
RELIABLE_INTERNET_SERVER_NAME=google.com


echo "Checking current network status..."

if ping -c 2 ${GATEWAY_IP} 1>/dev/null 2>&1; then

	echo "Gateway IP (${GATEWAY_IP}) responding, internal network connectivy ok."
	if ping -c 2 ${GATEWAY_NAME} 1>/dev/null 2>&1; then

		echo "Gateway DNS name (${GATEWAY_NAME}) responding, internal DNS ok."

		if ping -c 2 ${RELIABLE_INTERNET_SERVER_IP} 1>/dev/null 2>&1; then

			echo "Reliable internet server IP (${RELIABLE_INTERNET_SERVER_IP}) responding, external network connectivy ok."

			if ping -c 2 ${RELIABLE_INTERNET_SERVER_NAME} 1>/dev/null 2>&1; then

				echo "Reliable internet server DNS name (${RELIABLE_INTERNET_SERVER_NAME}) responding, external DNS ok."

				echo "Everything seems to be fine!"

			else

				echo "Reliable internet server DNS name (${RELIABLE_INTERNET_SERVER_NAME}) not responding, external DNS ko?"
				exit 4

			fi

		else

			echo "Reliable internet server IP (${RELIABLE_INTERNET_SERVER_IP}) not responding, external network connectivy ko?"
			exit 3

		fi

	else

		echo "Gateway DNS name (${GATEWAY_NAME}) not responding, internal DNS ko?"
		exit 2
	fi

else

	echo "Gateway IP (${GATEWAY_IP}) not responding, internal network connectivy ko?"
	echo "Pinging now continuously to know when network is back"

	ping ${GATEWAY_IP}

	exit 1

fi
