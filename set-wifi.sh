#!/bin/sh

wifi_if="eth1"
network_name="My Wifi Network"
ascii_key="1example9"

echo "	Setting up now wifi network '${network_name}' with ASCII password '${ascii_key}' on interface ${wifi_if}:"

iwconfig ${wifi_if} essid "${network_name}" mode managed key s:${ascii_key} 1>/dev/null
res=$?

if [ $res -eq 0 ] ; then
	
	echo "	Interface up, requesting DHCP lease."
	
	dhclient ${wifi_if} 1>/dev/null
	
	res=$?
	
	if [ $res -eq 0 ] ; then
	
		echo "	DHCP lease obtained, testing ping."
		
		host="google.com"
		
		if ping -c 5 ${host}; then
			
			echo "	Success, wifi connection ready!"
		
		else
		
			echo "	Error, unable to ping testing host (${host})." 1>&2
			
			exit 10
		
		fi
	
	else
	
			echo "	Error, unable to obtain a DHCP lease." 1>&2
			
			exit 6
		
	fi


else

	echo "	Error, unable to set interface ${wifi_if} up." 1>&2
			
	exit 4
	
fi		
		
	 
