#!/bin/sh
if [ ! `id -u` = "0" ] ; then

	echo "  Error, firewall rules can only be applied by root." 1>&2

	exit 10

fi

iptables=/sbin/iptables

(

	echo
	echo " - listing all 'filter' rules:"
	echo

	${iptables} -L

	echo
	echo " - printing all 'filter' rules:"
	echo
	${iptables} -S


	echo
	echo " - listing all 'nat' rules:"
	echo
	${iptables} -t nat -L

	echo
	echo " - printing all 'nat' rules:"
	echo
	${iptables} -t nat -S )  | more
