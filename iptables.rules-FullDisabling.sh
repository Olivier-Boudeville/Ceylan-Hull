#!/bin/sh


if [ ! `id -u` -eq 0 ] ; then

	echo "
	Error, you must be root, aborting." 1>&2

	exit 1

fi



echo "Disabling permanently ALL iptables rules (beware, all traffic accepted!)."

# Mangle removed, to avoid:

#iptables v1.4.20: can't initialize iptables table `mangle': Table does not exist (do you need to insmod?)
#Perhaps iptables or your kernel needs to be upgraded.

# With mangle:
#iptables -F && iptables -X && iptables -t nat -F && iptables -t nat -X && iptables -t mangle -F && iptables -t mangle -X && iptables -P INPUT ACCEPT && iptables -P FORWARD ACCEPT && iptables -P OUTPUT ACCEPT

# Without mangle:
iptables -F && iptables -X && iptables -t nat -F && iptables -t nat -X && iptables -P INPUT ACCEPT && iptables -P FORWARD ACCEPT && iptables -P OUTPUT ACCEPT

# Tables that could be added: mangle, raw and security.

if [ ! $? -eq 0 ] ; then

	echo "
	Error, disabling failed." 1>&2

	exit 15

else

	echo "Disabling succeeded."

fi
