#!/bin/sh



### BEGIN INIT INFO
# Provides:          iptables.rules-Gateway
# Required-Start:    $all
# Required-Stop:     $all
# Default-Start:     2 3 4 5
# Default-Stop:      0 1 6
# Short-Description: Starts our iptables-based firewall for gateways.
# Description:       Starts our iptables-based firewall for gateways.
### END INIT INFO


# This script configures the firewall for a (typically ADSL) gateway.

# Written by Robert Penz (robert.penz@outertech.com).
# This script is under GPL.

# Adapted from GNU Linux Magazine France, number 83 (may 2006), p.14 (article
# written by Christophe Grenier, grenier@cgsecurity.org)

# To debug this kind of firewall script, one may use:
# sh -x /path/to/this/file

# This script is meant to be copied in /etc/init.d, to be set as executable, and
# to be registered for future automatic launches by using: 'update-rc.d
# iptables.rules-Gateway defaults' (better than being directly set as the target
# of a symbolic link in: cd /etc/rc2.d && ln -s
# ../init.d/iptables.rules-Gateway.sh).


# Note: if 'modprobe iptables' fails because of tables not being found, it is
# the sign that the corresponding kernel modules could not be loaded. This often
# happens when the kernel modules on disk have been already updated while the
# currently running kernel, dating from latest boot, is lingering
# behind. Solution: rebooting and ensuring these kernel modules are loaded at
# boot.


# Adapted for Arch Linux and Systemd (see
# https://wiki.archlinux.org/index.php/Iptables).

# Adapted from script 'iptables.rules.ppp' by Olivier Boudeville, 2003, June 22.


# To use it in the context of Arch Linux:
#
#  - run this script as root, with: ./iptables.rules-Geteway.sh start
#
#  - copy the resulting state of iptables in the relevant file: iptables-save >
# /etc/iptables/iptables.rules
#
#  - reload the firewall: systemctl reload iptables
#
#  - check it just for this session: iptables -L
#
#  - check that iptables is meant to be started at boot: systemctl is-enabled
# iptables.service ; if not, run: systemctl enable iptables.service

# Note: for IPv6, use 'ip6tables' instead of 'iptables'.

# A 'logdrop' rule could be defined.


if [ ! $(id -u) -eq 0 ] ; then

	echo "  Error, firewall rules can only be applied by root." 1>&2

	exit 10

fi


# To debug more easily, by printing each line being executed first:
#set -x

# Causes the script to exit on error as soon as a command failed.
# Disabled, as some commands may fail (ex: modprobe)
#set -e


# Not used anymore by distros like Arch:
INIT_FILE="/lib/lsb/init-functions"

if [ -f "$INIT_FILE" ] ; then
	. "$INIT_FILE"
fi



# Useful with iptables --list|grep '\[v' or iptables -L -n |grep '\[v' to check
# whether rules are up-to-date.
# s is for server (log prefix must be shorter than 29 characters):
version="s-11"

# Full path of the programs we need, change them to your needs:
iptables=/sbin/iptables
modprobe=/sbin/modprobe
echo=/bin/echo
lsmod=/sbin/lsmod
rmmod=/sbin/rmmod

LOG_FILE=/root/.lastly-gateway-firewalled.touched

# Local (LAN) interface:
#LAN_IF=eth1
LAN_IF=enp2s0


# Internet interface:

# For PPP ADSL connections:
#NET_IF=ppp0

# For direct connection to a set-top box from your provider:
#NET_IF=eth0
NET_IF=enp4s0


# Tells whether Orge trafic should be allowed:
enable_orge=true


start_it_up()
{

	$echo "Setting Gateway firewall rules, version $version."
	touch $LOG_FILE

	# Only needed for older distros that do load ipchains by default, just
	# unload it:
	#
	if $lsmod 2>/dev/null | grep -q ipchains ; then
		$rmmod ipchains
	fi

	# Load appropriate modules:
	$modprobe ip_tables

	# We load these modules as we want to do stateful firewalling:
	$modprobe ip_conntrack
	$modprobe ip_conntrack_ftp
	$modprobe ip_conntrack_irc

	# Starts by disabling IP forwarding:
	$echo "0" > /proc/sys/net/ipv4/ip_forward

	# These lines are here in case rules are already in place and the script is
	# ever rerun on the fly.
	#
	# We want to remove all rules and pre-exisiting user defined chains and zero
	# the counters before we implement new rules:
	#
	${iptables} -F
	${iptables} -X
	${iptables} -Z

	${iptables} -F -t nat
	${iptables} -X -t nat
	${iptables} -Z -t nat


	# Set up a default DROP policy for the built-in chains.
	#
	# If we modify and re-run the script mid-session then (because we have a
	# default DROP policy), what happens is that there is a small time period
	# when packets are denied until the new rules are back in place.
	#
	# There is no period, however small, when packets we do not want are
	# allowed.
	#
	${iptables} -P INPUT DROP
	${iptables} -P FORWARD DROP
	${iptables} -P OUTPUT DROP

	## ============================================================
	## Kernel flags

	# To dynamically change kernel parameters and variables on the fly, you need
	# CONFIG_SYSCTL defined in your kernel.

	# Enable response to ping in the kernel, but we will only answer if the rule
	# at the bottom of the file let us:
	$echo "0" > /proc/sys/net/ipv4/icmp_echo_ignore_all

	# Disable response to broadcasts.
	# You do not want yourself becoming a Smurf amplifier:
	$echo "1" > /proc/sys/net/ipv4/icmp_echo_ignore_broadcasts

	# Do not accept source routed packets.
	#
	# Attackers can use source routing to generate traffic pretending to be from
	# inside your network, but which is routed back along the path from which it
	# came, namely outside, so attackers can compromise your network. Source
	# routing is rarely used for legitimate purposes:
	$echo "0" > /proc/sys/net/ipv4/conf/all/accept_source_route

	# Disable ICMP redirect acceptance. ICMP redirects can be used to alter your
	# routing tables, possibly to a bad end:
	$echo "0" > /proc/sys/net/ipv4/conf/all/accept_redirects

	# Enable bad error message protection:
	$echo "1" > /proc/sys/net/ipv4/icmp_ignore_bogus_error_responses

	# Turn on reverse path filtering. This helps make sure that packets use
	# legitimate source addresses, by automatically rejecting incoming packets
	# if the routing table entry for their source address does not match the
	# network interface they are arriving on.
	#
	# This has security advantages because it prevents so-called IP spoofing,
	# however it can pose problems if you use asymmetric routing (packets from
	# you to a host take a different path than packets from that host to you),
	# or if you operate a non-routing host which has several IP addresses on
	# different interfaces.
	#
	# Note: if you turn on IP forwarding, you will also get this:
	for interface in /proc/sys/net/ipv4/conf/*/rp_filter; do
		$echo "1" > ${interface}
	done

	# Log spoofed packets, source routed packets, redirect packets.
	$echo "1" > /proc/sys/net/ipv4/conf/all/log_martians

	# Make sure that IP forwarding is turned on, as it is a gateway:
	$echo "1" > /proc/sys/net/ipv4/ip_forward


	## ============================================================
	# RULES


	# ----------------  FORWARD ---------------------

	## We are masquerading:
	${iptables} -t nat -A POSTROUTING -o ${NET_IF} -s 192.168.0.0/24 -j MASQUERADE

	# With ADSL connections, NAT reduces the MTU, counter-measure:
	${iptables} -A FORWARD -p tcp --tcp-flags SYN,RST SYN -j TCPMSS -o ${NET_IF} --clamp-mss-to-pmtu

	# Only forward that stuff from one interface to the other, and do that with
	# connection tracking:

	# Everything from the LAN to the Internet is forwarded:
	${iptables} -A FORWARD -i ${LAN_IF} -o ${NET_IF} -m state --state NEW,ESTABLISHED,RELATED -j ACCEPT

	# Packets from the Internet to the LAN must not be new unknown connections:
	${iptables} -A FORWARD -o ${LAN_IF} -i ${NET_IF} -m state --state ESTABLISHED,RELATED -j ACCEPT

	AD_FILTER_PORT=3129
	## Transparent proxy
	#
	# Redirects http traffic to port $AD_FILTER_PORT where our ad filter is
	# running. Normal squid port is 3128.
	#
	#${iptables} -t nat -A PREROUTING -i ${LAN_IF} -p tcp --dport 80 -j REDIRECT --to-port $AD_FILTER_PORT


	# ----------------  OUTPUT ---------------------

	# No unroutable (private) adddress should be output by the gateway:
	${iptables} -A OUTPUT -o ${NET_IF} -d 10.0.0.0/8     -j REJECT
	${iptables} -A OUTPUT -o ${NET_IF} -d 127.0.0.0/8    -j REJECT
	${iptables} -A OUTPUT -o ${NET_IF} -d 172.16.0.0/12  -j REJECT
	${iptables} -A OUTPUT -o ${NET_IF} -d 192.168.0.0/16 -j REJECT


	# Second rule is to let packets through which belong to established or
	# related connections and we let all traffic out, as we trust ourself:
	${iptables} -A OUTPUT -m state --state NEW,ESTABLISHED,RELATED -j ACCEPT


	# ----------------  INPUT ---------------------


	# Log some invalid connections:
	# (disabled, as uselessly verbose)

	#${iptables} -A INPUT -m state --state INVALID -m limit --limit 2/s -j LOG --log-prefix "[v.$version: invalid input] "

	${iptables} -A INPUT -m state --state INVALID -j DROP

	# Filter out broadcasts:
	${iptables} -A INPUT -m pkttype --pkt-type broadcast -j DROP


	# Drops directly connections coming from the Internet with unroutable
	# (private) addresses:
	${iptables} -A INPUT -i ${NET_IF} -s 10.0.0.0/8     -j DROP
	${iptables} -A INPUT -i ${NET_IF} -s 127.0.0.0/8    -j DROP
	${iptables} -A INPUT -i ${NET_IF} -s 172.16.0.0/12  -j DROP
	${iptables} -A INPUT -i ${NET_IF} -s 192.168.0.0/16 -j DROP


	# Avoid stealth TCP port scans if SYN is not set properly:
	${iptables} -A INPUT -m state --state NEW,RELATED -p tcp ! --tcp-flags ALL SYN -j DROP

	# Rejects directly 'auth/ident' obsolete requests:
	${iptables} -A INPUT -p tcp --dport auth -j REJECT --reject-with tcp-reset

	${iptables} -A INPUT -m state --state ESTABLISHED,RELATED -j ACCEPT

	## FRAGMENTS
	#
	# Fragments are scaring, sending lots of non-first fragments was what
	# allowed Jolt2 to effectively "drown" Firewall-1.
	#
	# Fragments can be overlapped, and the subsequent interpretation of such
	# fragments is very OS-dependent.
	#
	# We are not going to trust any fragments.
	# Log fragments just to see if we get any, and deny them too.
	${iptables} -A INPUT -f -j LOG --log-prefix "[v.$version: iptables fragments] "
	${iptables} -A INPUT -f -j DROP

	 ## HTTP (web server):
	${iptables} -A INPUT -p tcp --dport 80 -m state --state NEW -j ACCEPT

	# HTTPS:
	#${iptables} -A INPUT -p tcp --dport 443 -m state --state NEW -j ACCEPT

	## ident, if we drop these packets we may need to wait for the timeouts
	# e.g. on ftp servers
	${iptables} -A INPUT -p tcp --dport 113 -m state --state NEW -j REJECT

	## FTP:
	# (not used anymore - prefer SFTP, hence on the same port as SSH, instead)
	#
	#${iptables} -A INPUT -p tcp --dport 20 -m state --state NEW -j ACCEPT
	#${iptables} -A INPUT -p tcp --dport 21 -m state --state NEW -j ACCEPT


	# Orge section:

	if [ $enable_orge = "true" ] ; then

		# For Erlang epmd daemon:
		${iptables} -A INPUT -p tcp --dport 4369 -m state --state NEW -j ACCEPT

		# For the listening socket of TCP Orge server:
		${iptables} -A INPUT -p tcp --dport 9512 -m state --state NEW -j ACCEPT


		# For passive FTP and client TCP Orge server sockets:
		${iptables} -A INPUT -p tcp --dport 51000:51999 -m state --state NEW,ESTABLISHED,RELATED -j ACCEPT

		# For main UDP Orge server socket:
		${iptables} -A INPUT -p udp --dport 9512 -m state --state NEW -j ACCEPT

	fi

	## SSH:

	# One may use a non-standard port:
	#SSH_PORT=22
	SSH_PORT=44324

	# Unlimited input from LAN:
	${iptables} -A INPUT -i ${LAN_IF} -p tcp --dport ${SSH_PORT} -m state --state NEW -j ACCEPT

	# This rules allow to prevent brute-force SSH attacks by limiting the
	# frequency of attempts coming from the Internet:

	# Logs too frequent attempts tagged with 'SSH' and drops them:
	${iptables} -A INPUT -i ${NET_IF} -p tcp --dport ${SSH_PORT} -m recent --update --seconds 60 --hitcount 4 --name SSH -j LOG --log-prefix "[v.$version: SSH brute-force] "

	${iptables} -A INPUT -i ${NET_IF} -p tcp --dport ${SSH_PORT} -m recent --update --seconds 60 --hitcount 4 --name SSH -j DROP

	# Tags too frequent SSH attempts with the name 'SSH':
	${iptables} -A INPUT -i ${NET_IF} -p tcp --dport ${SSH_PORT} -m recent --set --name SSH

	# Accepts nevertheless normal SSH logins:
	${iptables} -A INPUT -i ${NET_IF} -p tcp --dport ${SSH_PORT} -j ACCEPT


	## Mail stuff:
	#$iptables -A INPUT -p tcp --dport 25  -m state --state NEW -j ACCEPT
	#$iptables -A INPUT -p tcp --dport 110 -m state --state NEW -j ACCEPT
	#$iptables -A INPUT -p tcp --dport 143 -m state --state NEW -j ACCEPT
	#$iptables -A INPUT -p tcp --dport 993 -m state --state NEW -j ACCEPT
	#$iptables -A INPUT -p tcp --dport 995 -m state --state NEW -j ACCEPT

	# Allow UDP & TCP packets to the DNS server from LAN clients (only needed if
	# this gateway is a LAN DNS server).
	#
	${iptables} -A INPUT -i ${LAN_IF} -p tcp --dport 53 -m state --state NEW -j ACCEPT
	${iptables} -A INPUT -i ${LAN_IF} -p udp --dport 53 -m state --state NEW -j ACCEPT


	# NUT, for UPS monitoring:
	${iptables} -A INPUT -i ${LAN_IF} -p tcp --dport 3493 -m state --state NEW -j ACCEPT
	${iptables} -A INPUT -i ${LAN_IF} -p udp --dport 3493 -m state --state NEW -j ACCEPT


	# Squid (only local)
	#${iptables} -A INPUT -p tcp -i ${LAN_IF} --dport 3128:3129 -m state --state NEW -j ACCEPT


	# Allow the smb stuff (only local)
	#${iptables} -A INPUT -i ${LAN_IF} -p udp --dport 137:139 -m state --state NEW -j ACCEPT
	#${iptables} -A INPUT -i ${LAN_IF} -p tcp --dport 137:139 -m state --state NEW -j ACCEPT

	# GnomeMeeting:
	#${iptables} -A INPUT -p tcp --dport 30000:33000 -j ACCEPT
	#${iptables} -A INPUT -p tcp --dport 1720 -j ACCEPT
	#${iptables} -A INPUT -p udp --dport 5000:5006 -j ACCEPT

	## LOOPBACK
	# Allow unlimited traffic on the loopback interface, e.g. needed for KDE,
	# Gnome, etc.:
	${iptables} -A INPUT  -i lo -j ACCEPT
	${iptables} -A OUTPUT -o lo -j ACCEPT


	# ---------------- ICMP ---------------------

	# Everybody from the LAN can ping me (but no one from the Internet):
	# Remove that line if no one should be able to ping you
	${iptables} -A INPUT -i ${LAN_IF} -p icmp --icmp-type ping -j ACCEPT


	# ---------------- NTP ---------------------

	# Local clients can ask for gateway-synchronized time:
	${iptables} -A INPUT -i ${LAN_IF} -p udp --dport 123 -m state --state NEW,ESTABLISHED,RELATED -j ACCEPT


	# ---------------- LOGGING -------------------

	# Log everything else, up to 2 pings per min:
	#
	# (should be disabled if connected to the Internet, as far too verbose in
	# system logs, might hide other important events)
	#
	#${iptables} -A INPUT -m limit --limit 2/minute -j LOG

}


shut_it_down()
{

	# Not only one may end up not being protected, but one may also be locked
	# out of the gateway if this command is issued remotely, e.g. through SSH,
	# whose connection will be lost after this call, preventing from restarting
	# the service again...

	$echo "Disabling Gateway firewall rules, version $version (DANGER!)."

	# Load appropriate modules:
	$modprobe ip_tables

	# We remove all rules and pre-exisiting user defined chains and zero the
	# counters before we implement new rules:
	$iptables -F
	$iptables -X
	$iptables -Z

	$iptables -F -t nat
	$iptables -X -t nat
	$iptables -Z -t nat

}


script_name=$(basename $0)

case "$1" in
  start)
	start_it_up
  ;;
  stop)
	shut_it_down
  ;;
  reload|force-reload)
	shut_it_down
	start_it_up
  ;;
  restart)
	shut_it_down
	start_it_up
  ;;
  status)
	iptables -L
  ;;
  *)

	echo " Error, no appropriate action specified." >&2

	if [ -z "$NAME" ] ; then
		# Launched from the command-line:
		echo "Usage: $script_name {start|stop|reload|restart|force-reload|status}" >&2

	else

		echo "Usage: /etc/init.d/$NAME {start|stop|reload|restart|force-reload|status}" >&2

	fi

	exit 2

  ;;

esac

exit 0
