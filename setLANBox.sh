#!/bin/sh

echo "Configuring $HOSTNAME as a LAN box"

if [ -e /etc/ppp/ppp_on_boot ]; then
	mv /etc/ppp/ppp_on_boot /etc/ppp/disabled-ppp_on_boot
fi

NETMASK=255.255.255.0
LAN_NET=192.168.0.0
GATEWAY=192.168.0.1
MY_IP=192.168.0.3

ETH_LAN=eth0
ETH_INTERNET=eth1

ROUTE=/sbin/route
IFCONFIG=/sbin/ifconfig

echo "Managing interfaces"

echo -e "\t+ Adding loopback interface"
$IFCONFIG lo 127.0.0.1

echo -e "\t+ Adding LAN access : interface $ETH_LAN set to IP $MY_IP"
$IFCONFIG $ETH_LAN $MY_IP

echo -e "\t+ Disabling interface $ETH_INTERNET"
$IFCONFIG $ETH_INTERNET down


echo "Managing routes"


echo -e "\t+ Adding loopback route"
$ROUTE add 127.0.0.0 lo

echo -e "\t+ All LAN-targeted (to network $LAN_NET) packets should be routed to $ETH_LAN"
$ROUTE add $LAN_NET $ETH_LAN

echo -e "\t+ Default route aimed at gateway $GATEWAY"
$ROUTE add default gw $GATEWAY

