#!/bin/sh

echo "Setting NAT"

echo "Loading the NAT module iptable_nat (this pulls in all the others)"
modprobe iptable_nat


# In the NAT table (-t nat), Append a rule (-A) after routing
# (POSTROUTING) for all packets going out ppp0 (-o ppp0) which says to
# MASQUERADE the connection (-j MASQUERADE).

echo "Launching iptables with NAT settings"
iptables -t nat -A POSTROUTING -o ppp0 -j MASQUERADE

echo "Turn on IP forwarding"
echo 1 > /proc/sys/net/ipv4/ip_forward
