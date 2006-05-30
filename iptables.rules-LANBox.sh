#!/bin/bash

# Adapted from script 'iptables.rules' by Olivier Boudeville, 2003, June 22.

# This script configures the firewall for a mere LAN box client.

# Written by Robert Penz (robert.penz@outertech.com)
# This script is under GPL

# full path of the programs we need - changed them to your needs
iptables=/sbin/iptables
modprobe=/sbin/modprobe
echo=/bin/echo
 
echo "Setting LAN box firewall rules"

 
# only needed for older distris that do load ipchains by default, just unload it.
if  /sbin/lsmod 2>/dev/null |grep -q ipchains ; then 
	rmmod ipchains
fi 

# Load appropriate modules. 
#$modprobe ip_tables 		# useless, compiled in kernel

# we load that modules as we want to do statefull firewalling
#$modprobe ip_conntrack 		# useless, compiled in kernel
#$modprobe ip_conntrack_ftp  # useless, compiled in kernel
$modprobe ip_conntrack_irc  # needed module indeed


# These lines are here in case rules are already in place and the script is ever rerun on the fly. 
# We want to remove all rules and pre-exisiting user defined chains and zero the counters 
# before we implement new rules. 
$iptables -F 
$iptables -X 
$iptables -Z 

# Set up a default DROP policy for the built-in chains. 
# If we modify and re-run the script mid-session then (because we have a default DROP 
# policy), what happens is that there is a small time period when packets are denied until 
# the new rules are back in place. There is no period, however small, when packets we 
# don't want are allowed. 
$iptables -P INPUT DROP 
$iptables -P FORWARD DROP 
$iptables -P OUTPUT DROP 

## ============================================================ 
## Kernel flags 
# To dynamically change kernel parameters and variables on the fly you need 
# CONFIG_SYSCTL defined in your kernel. I would advise the following: 

# Enable response to ping in the kernel but we'll only answer if 
# the rule at the bottom of the file let us. 
$echo "0" > /proc/sys/net/ipv4/icmp_echo_ignore_all 

# Disable response to broadcasts. 
# You don't want yourself becoming a Smurf amplifier. 
$echo "1" > /proc/sys/net/ipv4/icmp_echo_ignore_broadcasts 

# Don't accept source routed packets. Attackers can use source routing to generate 
# traffic pretending to be from inside your network, but which is routed back along 
# the path from which it came, namely outside, so attackers can compromise your 
# network. Source routing is rarely used for legitimate purposes. 
$echo "0" > /proc/sys/net/ipv4/conf/all/accept_source_route 

# Disable ICMP redirect acceptance. ICMP redirects can be used to alter your routing 
# tables, possibly to a bad end. 
$echo "0" > /proc/sys/net/ipv4/conf/all/accept_redirects 

# Enable bad error message protection. 
$echo "1" > /proc/sys/net/ipv4/icmp_ignore_bogus_error_responses 

# Turn on reverse path filtering. This helps make sure that packets use 
# legitimate source addresses, by automatically rejecting incoming packets 
# if the routing table entry for their source address doesn't match the network 
# interface they're arriving on. This has security advantages because it prevents 
# so-called IP spoofing, however it can pose problems if you use asymmetric routing 
# (packets from you to a host take a different path than packets from that host to you) 
# or if you operate a non-routing host which has several IP addresses on different 
# interfaces. (Note - If you turn on IP forwarding, you will also get this). 
for interface in /proc/sys/net/ipv4/conf/*/rp_filter; do 
   $echo "1" > ${interface} 
done 

# Log spoofed packets, source routed packets, redirect packets. 
#$echo "1" > /proc/sys/net/ipv4/conf/all/log_martians 

# Make sure that IP forwarding is turned off. We only want this for a multi-homed host. 
# Remember : this is for a LAN box (mere client)
$echo "0" > /proc/sys/net/ipv4/ip_forward 



## ============================================================ 
# RULES 

## First rule is to let packets through which belong to establisted or related connection
# and we let all traffic out as we trust ourself.
$iptables -A OUTPUT -m state --state NEW,ESTABLISHED,RELATED -j ACCEPT
$iptables -A INPUT  -m state --state 	 ESTABLISHED,RELATED -j ACCEPT


# ----------------  INPUT ---------------------

## FRAGMENTS 
# I have to say that fragments scare me more than anything. 
# Sending lots of non-first fragments was what allowed Jolt2  to effectively "drown" 
# Firewall-1. Fragments can be overlapped, and the subsequent interpretation of such 
# fragments is very OS-dependent. 
# I am not going to trust any fragments. 
# Log fragments just to see if we get any, and deny them too. 
#$iptables -A INPUT -f -j LOG --log-prefix "IPTABLES FRAGMENTS: " 
$iptables -A INPUT -f -j DROP 

## apache stuff
#$iptables -A INPUT -p tcp --dport 80 -m state --state NEW -j ACCEPT
#$iptables -A INPUT -p tcp --dport 443 -m state --state NEW -j ACCEPT

## ident, if we drop these packets we may need to wait for the timeouts
# e.g. on ftp servers
$iptables -A INPUT -p tcp --dport 113 -m state --state NEW -j REJECT

## ftp
#$iptables -A INPUT -p tcp --dport 21 -m state --state NEW -j ACCEPT

## ssh
$iptables -A INPUT -p tcp --dport 22 -m state --state NEW -j ACCEPT

## mail stuff
#$iptables -A INPUT -p tcp --dport 25 -m state --state NEW -j ACCEPT
#$iptables -A INPUT -p tcp --dport 110 -m state --state NEW -j ACCEPT
#$iptables -A INPUT -p tcp --dport 143 -m state --state NEW -j ACCEPT
#$iptables -A INPUT -p tcp --dport 993 -m state --state NEW -j ACCEPT
#$iptables -A INPUT -p tcp --dport 995 -m state --state NEW -j ACCEPT

# Allow UDP & TCP packets to the DNS server from clients. (only need
# if this client is an DNS server)
#$iptables -A INPUT -p tcp --dport 53 -m state --state NEW -j ACCEPT
#$iptables -A INPUT -p udp --dport 53 -m state --state NEW -j ACCEPT

## LOOPBACK
# Allow unlimited traffic on the loopback interface.
# e.g. needed for KDE, Gnome
$iptables -A INPUT -i  lo -j ACCEPT
$iptables -A OUTPUT -o lo -j ACCEPT

# ---------------- ICMP ---------------------

# all can ping me - remove that line if no one should be able to ping you
$iptables -A INPUT -p icmp --icmp-type ping -j ACCEPT

# ---------------- LOGGING -------------------

# log every thing else, up to 5 pings per min
 #$iptables -A INPUT -m limit --limit 5/minute -j LOG


