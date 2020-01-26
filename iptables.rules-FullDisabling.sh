#!/bin/sh

if [ ! $(id -u) -eq 0 ] ; then

	echo "
	Error, you must be root, aborting." 1>&2
	exit 5

fi


echo "Disabling *permanently* ALL iptables rules (beware, all traffic accepted!)."


iptables=/sbin/iptables

${iptables} -F && ${iptables} -X && ${iptables} -Z && ${iptables} -F -t nat && ${iptables} -X -t nat && ${iptables} -Z -t nat && ${iptables} -P INPUT ACCEPT && ${iptables} -P FORWARD ACCEPT && ${iptables} -P OUTPUT ACCEPT


if [ ! $? -eq 0 ] ; then

	echo "
	Error, disabling failed." 1>&2

	exit 15

else

	echo "Disabling succeeded."

fi
