#!/bin/sh

wifi_if="eth1"
network_name="My Wifi Network"
ascii_key="1example9"

# Manual procedure, as root:
#
# Once for all: 'apt-get install wireless-tools wpasupplicant'
#
# Then:
#
# - we search for an appropriate interface:
# /sbin/iwconfig 2>&1 | grep -v 'no wireless extensions.'
# This yields for example:
# wlan0     IEEE 802.11bg  ESSID:off/any
#		  Mode:Managed  Access Point: Not-Associated   Tx-Power=off
#		  Retry  long limit:7   RTS thr:off   Fragment thr:off
#		  Power Management:off
#
# Here wifi_if=wlan0
#
# - then we configure this wireless interface:
# iwconfig $wifi_if essid "My network" key 16a12bd649ced7ce42ee3f383f
#
# - then we try to establish the wiki connection with the access point:
# ifconfig $wifi_if up
#
# - finally we request information thanks to DHCP:
# dhclient $wifi_if
#
# Note that some wifi chips must be enabled by pushing the right button and/or
# require the computer to be rebooted once having been activated or after
# hibernation. Also, the 'NetworkManager' daemon may try to do the same in the
# background and mess with your attempts.



if [ ! `id -u` -eq 0 ] ; then

	echo "   Error, this script must be run as root." 1>&2

	exit 5

fi


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
