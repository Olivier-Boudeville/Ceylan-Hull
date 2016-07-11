#!/bin/sh

USAGE="Usage: $(basename $0): sets USB tethering on local host, typically so that a linked smartphone provides it an Internet access."

#echo $USAGE

if [ ! $(id -u) -eq 0 ] ; then

	echo "  Error, you must be root." 1>&2
	exit 5

fi

IP=$(which ip 2>/dev/null)

if [ ! -x "${IP}" ] ; then

	echo "  Error, 'ip' tool not available." 1>&2
	exit 10

fi

DHCPCD=$(which dhcpcd 2>/dev/null)

if [ ! -x "${DHCPCD}" ] ; then

	echo "  Error, 'dhcpcd' tool not available." 1>&2
	exit 15

fi

# Extract for example 'enp0s18f2u1' from '24: enp0s18f2u1: <BROADCAST,MULTICAST...'
IF_NAME=$($IP addr | grep ': enp' | sed 's|^[[:digit:]]\+\.*\: ||1' | sed 's|\: .*$||1')

#echo "IF_NAME = $IF_NAME"

echo "Using auto-detected interface $IF_NAME..."

# Ensures that the daemon is not already runnning:
$DHCPCD -k $IF_NAME 1>/dev/null 2>&1

$DHCPCD $IF_NAME 1>/dev/null

if [ $? -eq 0 ] ; then

	if ping -c 1 google.com 1>/dev/null 2>&1 ; then

		echo "Connection up and running. Enjoy!"
		exit 0

	else

		echo " Error, connection established yet does not seem functional." 1>&2
		exit 30

	fi

else

	echo " Error, unable to obtain an IP address from interface." 1>&2
	exit 20

fi
