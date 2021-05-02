#!/bin/sh

USAGE="Usage: $(basename $0) [--stop]: sets (or stops) USB tethering on local host, typically so that a linked smartphone provides it with an Internet access."

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

ESPEAK=$(which espeak 2>/dev/null)

notify()
{

	MESSAGE="$1"

	echo "${MESSAGE}"

	if [ -x "${ESPEAK}" ] ; then
		${ESPEAK} -v female1 "${MESSAGE}" 1>/dev/null 2>&1
	fi

}


# Extract for example 'enp0s18f2u1' from '24: enp0s18f2u1: <BROADCAST,MULTICAST...'
IF_NAME=$($IP addr | grep ': enp0' | sed 's|^[[:digit:]]\+\.*\: ||1' | sed 's|\: .*$||1')

if [ -z "${IF_NAME}" ] ; then

	echo " Error, no relevant network interface found (is USB tethering activated on the phone, typically in Settings -> Network and Internet -> Access point and connection sharing?)." 1>&2
	#ip addr 1>&2
	exit 18

fi


#echo "IF_NAME = $IF_NAME"


if [ "$1" = "--stop" ]; then

	echo "Disabling connection on auto-detected interface $IF_NAME..."

	${IP} link set dev ${IF_NAME} down && echo "...done"

	exit 0

fi

if [ -n "$1" ] ; then

	echo "  Error, parameter '$1' not supported.
$USAGE" 1>&2
	exit 25

fi



echo "Enabling connection using auto-detected interface $IF_NAME..."


RETRIES=3



connect()
{

	# Ensures that the daemon is not already runnning:
	$DHCPCD -k $IF_NAME 1>/dev/null 2>&1

	$DHCPCD $IF_NAME 1>/dev/null

	if [ $? -eq 0 ] ; then

		# Fix routes (only gateway needed, not full network):
		ip route del 192.168.0.0/24 dev $IF_NAME
		ip route add 192.168.0.1 dev $IF_NAME

		if test_link ; then

			notify "Connection up and running. Enjoy!"

			exit 0

		else

			if [ $RETRIES -eq 0 ] ; then

				echo " Error, connection established yet does not seem functional, all retries failed, giving up." 1>&2
				exit 20

			else

				echo " Connection established yet does not seem functional, retrying..."
				RETRIES=$(($RETRIES-1))
				connect

			fi

		fi

	else

		if [ $RETRIES -eq 0 ] ; then

			notify " Error, unable to obtain an IP address from interface, all retries failed, giving up." 1>&2
			exit 25

		else

			echo "  Unable to obtain an IP address from interface, retrying..."
			RETRIES=$(($RETRIES-1))
			connect

		fi

	fi

}


test_link()
{

	# Otherwise could be too early for a ping to succeed:
	sleep 2

	ping -c 1 google.com 1>/dev/null 2>&1
	return $?
}

connect
