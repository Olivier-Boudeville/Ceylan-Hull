echo "Configuring $HOSTNAME as an ADSL gateway"

if [ ! -e  /etc/ppp/ppp_on_boot ]; then
	mv /etc/ppp/disabled-ppp_on_boot /etc/ppp/ppp_on_boot
fi

NETMASK=255.255.255.0
LAN_NET=192.168.0.0

MY_LAN_IP=192.168.0.3

ETH_LAN=eth0
ETH_INTERNET=eth1

ROUTE=/sbin/route
IFCONFIG=/sbin/ifconfig


echo "Managing interfaces"

echo -e "\t+ Adding loopback interface"
$IFCONFIG lo 127.0.0.1

echo -e "\t+ Adding LAN access : interface $ETH_LAN set to IP $MY_LAN_IP"
$IFCONFIG $ETH_LAN $MY_LAN_IP

echo -e "\t+ Enabling interface $ETH_INTERNET pto be used for ADSL (ppp0)"
$IFCONFIG $ETH_INTERNET up


echo "Managing routes"

echo -e "\t+ Adding loopback route"
$ROUTE add 127.0.0.0 lo

echo -e "\t+ All LAN-targeted (to network $LAN_NET) packets should be routed to $ETH_LAN"
$ROUTE add $LAN_NET $ETH_LAN

echo -e "\t+ No default route set, ppp will do it for us"

# Default route will be (after rc2.d) aimed at ppp0
# by S14ppp -> /etc/ppp/ppp_on_boot -> $PPPD call wanadoo.dsl -> /etc/ppp/peers/wanadoo.dsl
#$ROUTE add -net 0.0.0.0 netmask $NETMASK ppp0

