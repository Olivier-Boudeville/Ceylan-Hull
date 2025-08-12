#!/bin/sh

usage="Usage: $(basename $0): disables all firewall rules, alternatively to a measure akin to 'systemctl stop iptables.service'."


if [ "$1" = "-h" ] || [ "$1" = "--help" ]; then

	echo "${usage}"

	exit

fi


if [ -n "$1" ]; then

	echo "  Error, not argument expected.
${usage}" 1>&2

	exit 5

fi


# Generally /sbin/iptables:
iptables="$(which iptables 2>/dev/null)"

if [ ! -x "${iptables}" ]; then

	echo " Error, not 'iptables' executable found." 1>&2

	exit 10

fi


if [ ! $(id -u) -eq 0 ]; then

	echo "
	Error, you must be root; aborting." 1>&2
	exit 15

fi


echo "Disabling *permanently* ALL iptables rules (beware, all traffic accepted!)."


if ! "${iptables}" -F && "${iptables}" -X && "${iptables}" -Z && "${iptables}" -F -t nat && "${iptables}" -X -t nat && "${iptables}" -Z -t nat && "${iptables}" -P INPUT ACCEPT && "${iptables}" -P FORWARD ACCEPT && "${iptables}" -P OUTPUT ACCEPT; then

	echo "
	Error, iptables disabling failed." 1>&2

	exit 50

else

	echo "Disabling of iptables succeeded. Beware!"

fi
