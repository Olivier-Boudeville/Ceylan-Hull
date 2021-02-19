#!/bin/sh

usage="Usage: $(basename $0) [-h|--help] [--stop]: sets (or stops) USB tethering on local host, typically so that a smartphone connected through USB and with such tethering enabled shares its Internet connectivity with this host."


if [ ! $(id -u) -eq 0 ]; then

	echo "  Error, you must be root.
${usage}" 1>&2
	exit 5

fi

ip=$(which ip 2>/dev/null)

if [ ! -x "${ip}" ]; then

	echo "  Error, 'ip' tool not available." 1>&2
	exit 10

fi

if [ "$1" = "-h" ] || [ "$1" = "--help" ]; then

	echo "${usage}"
	exit

fi


dhcpcd=$(which dhcpcd 2>/dev/null)

if [ ! -x "${dhcpcd}" ]; then

	echo "  Error, 'dhcpcd' tool not available." 1>&2
	exit 15

fi

espeak=$(which espeak 2>/dev/null)

notify()
{

	message="$1"

	echo "${message}"

	if [ -x "${espeak}" ]; then
		${espeak} -v female1 "${message}" 1>/dev/null 2>&1
	fi

}


# Extract for example 'enp0s18f2u1' from '24: enp0s18f2u1:
# <BROADCAST,MULTICAST...'
#
if_name=$(${ip} addr | grep ': enp0' | sed 's|^[[:digit:]]\+\.*\: ||1' | sed 's|\: .*$||1')

if [ -z "${if_name}" ]; then

	echo " Error, no relevant network interface found (is USB tethering activated on the phone, typically, for Android ones, in: Settings -> Networks and Internet -> Acces Point and Connection Sharing -> Via USB)?" 1>&2
	#ip addr 1>&2
	exit 18

fi


#echo "if_name = ${if_name}"


if [ "$1" = "--stop" ]; then

	echo "Disabling connection on auto-detected interface ${if_name}..."

	${ip} link set dev ${if_name} down && echo "...done"

	exit 0

fi

if [ -n "$1" ]; then

	echo "  Error, parameter '$1' not supported.
$usage" 1>&2
	exit 25

fi


echo "Enabling connection using auto-detected interface ${if_name}..."

retries=3


connect()
{

	# Ensures that the daemon is not already runnning:
	${dhcpcd} -k ${if_name} 1>/dev/null 2>&1

	# Any past default route could still apply and remain the first, so:
	${ip} route del default 2>/dev/null

	${dhcpcd} ${if_name} 1>/dev/null

	if [ $? -eq 0 ]; then

		# Fix routes (only gateway needed, not full network):
		${ip} route del 192.168.0.0/24 dev ${if_name}
		${ip} route add 192.168.0.1 dev ${if_name}

		if test_link; then

			notify "Connection up and running. Enjoy!"

			exit 0

		else

			if [ ${retries} -eq 0 ]; then

				echo " Error, connection established yet does not seem functional, all retries failed, giving up." 1>&2
				exit 20

			else

				echo " Connection established yet does not seem functional, retrying..."
				retries=$((${retries}-1))
				connect

			fi

		fi

	else

		if [ ${retries} -eq 0 ]; then

			notify " Error, unable to obtain an ip address from interface, all retries failed, giving up." 1>&2
			exit 25

		else

			echo "  Unable to obtain an ip address from interface, retrying..."
			retries=$((${retries}-1))
			connect

		fi

	fi

}


test_link()
{

	# Otherwise could be too early for a ping to succeed:
	sleep 2

	# Both IP and DNS tested (otherwise: just ping 8.8.8.8)
	ping -c 1 google.com 1>/dev/null 2>&1
	return $?
}

connect
