#!/bin/sh


### BEGIN INIT INFO
# Provides:          iptables.rules-LANBox
# Required-Start:    $all
# Required-Stop:     $all
# Default-Start:     2 3 4 5
# Default-Stop:      0 1 6
# Short-Description: Starts our iptables-based firewall for LAN clients.
# Description:       Starts our iptables-based firewall for LAN clients.
### END INIT INFO


# This script configures the firewall for a mere LAN box client.

# Written by Robert Penz (robert.penz@outertech.com)
# This script is under GPL.

# Adapted from GNU Linux Magazine France, number 83 (may 2006), p.14
# (article written by Christophe Grenier, grenier@cgsecurity.org)

# This script is meant to be copied in /etc/init.d, to be set as executable, and
# to be registered for future automatic launches by using: 'update-rc.d
# iptables.rules-LANBox defaults' (better than being directly set as the target
# of a symbolic link in: cd /etc/rc2.d && ln -s
# ../init.d/iptables.rules-LANBox.sh).


# Note: if 'modprobe iptables' fails because of tables not being found, it is
# the sign that the corresponding kernel modules could not be loaded. This often
# happens when the kernel modules on disk have been already updated while the
# currently running kernel, dating from latest boot, is lingering
# behind. Solution: rebooting and ensuring these kernel modules are loaded at
# boot.


# Adapted for Arch Linux and Systemd (see
# https://wiki.archlinux.org/index.php/Iptables).

# Adapted from script 'iptables.rules' by Olivier Boudeville, 2003, June 22.


# To use it in the context of Arch Linux:
#
#  - run this script as root, with: ./iptables.rules-LANBox.sh start
#
#  - copy the resulting state of iptables in the relevant file (note: this
# filename cannot be changed, it is a system convention):
#
# iptables-save > /etc/iptables/iptables.rules
#
#  - restart the firewall: systemctl stop iptables ; systemctl start iptables ;
# systemctl status iptables
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
init_file="/lib/lsb/init-functions"

if [ -f "$init_file" ] ; then
	. "$init_file"
fi



# Useful with iptables --list|grep '\[v' or iptables -L -n |grep '\[v'
# to check whether rules are up-to-date.
# 'c' is for client (log prefix must be shorter than 29 characters):
version="c-10"

# Full path of the programs we need, change them to your needs:
iptables=/sbin/iptables
modprobe=/sbin/modprobe
echo=/bin/echo
lsmod=/sbin/lsmod
rmmod=/sbin/rmmod

log_file=/root/.lastly-LAN-firewalled.touched


detected_if=$(ip link | grep ': <' | sed 's|: <.*$||' | cut -d ' ' -f 2 | grep -v '^lo$')

if [ -z "$detected_if" ] ; then

   echo "  No LAN interface found!" 1>&2
   exit 25

fi

printf "* detected network interfaces: \n$detected_if"

# By default we select the first interface found:
lan_if=$(echo $detected_if | sed 's| .*$||1')

echo
echo
echo "* selected LAN interface: $lan_if"

if [ -z "$lan_if" ] ; then

   echo "  No LAN interface selected!" 1>&2
   exit 30

fi


# UPnp/DLNA section.
#
# Set to true iff this LAN computer is to host a DLNA server (ex: minidlna):
#
use_dlna="true"

dlna_http_port=8200



# EPMD (Erlang) section.


# By default, we do *not* filter out EPMD traffic (i.e. we accept it):
filter_epmd=1

# Over TCP:
epmd_default_port=4369

#epmd_port=$epmd_default_port

# Our default:
epmd_port=4506


# By default, we enable a range of unfiltered TCP ports:
enable_unfiltered_tcp_range=0

# TCP unfiltered window (ex: for passive FTP and BEAM port ranges):
tcp_unfiltered_low_port=50000
tcp_unfiltered_high_port=55000



start_it_up()
{

	$echo "Setting LAN box firewall rules, version $version."
	$echo "# ---- Setting LAN firewall rules, version $version, on $(date)." > $log_file

	# Only needed for older distros that do load ipchains by default, just
	# unload it:
	#
	#if $lsmod  2>/dev/null | grep -q ipchains ; then
	#	$rmmod ipchains
	#fi

	# Load appropriate modules:
	#
	# (was commented-out: this (correct) call returned an error and used to
	# cause the script to silently abort)
	#
	${modprobe} ip_tables

	# So that filtering rules can be commented:
	${modprobe} xt_comment

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

	# Log spoofed packets, source routed packets, redirect packets:
	$echo "1" > /proc/sys/net/ipv4/conf/all/log_martians

	# Make sure that IP forwarding is turned off.
	#
	# We only want this for a multi-homed host.
	# Remember: this is for a LAN box (mere client)
	$echo "0" > /proc/sys/net/ipv4/ip_forward


	## ============================================================
	# RULES

	# ---------------- PRIVACY  -------------------

	# This is an exception section, having mixed INPUT and OUTPUT rules.
	# It shall come first!

	use_ban_rules="true"
	#use_ban_rules="false"

	ban_file="/etc/ban-rules.iptables"

	if [ "$use_ban_rules" = "true" ] ; then

		if [ -f "${ban_file}" ] ; then

			$echo "Adding ban rules from '${ban_file}'."

			# May add useless FORWARD rules as well (expected to be harmless):
			. "${ban_file}"

			res=$?

			if [ ! $res -eq 0 ] ; then

				echo "  Error, the addition of ban rules failed." 1>&2

				exit 60

			fi

		else

			echo "  Error, ban rules enabled, yet ban file (${ban_file}) not found." 1>&2

			exit 61

		fi

	fi


	# ----------------  OUTPUT ---------------------

	## First rule is to let packets through which belong to established or
	# related connections and we let all traffic out as we trust ourself.
	${iptables} -A OUTPUT -m state --state NEW,ESTABLISHED,RELATED -j ACCEPT
	${iptables} -A INPUT  -m state --state ESTABLISHED,RELATED -j ACCEPT


	# ----------------  INPUT ---------------------

	# Log some invalid connections:
	# (disabled, as uselessly verbose)
	#${iptables} -A INPUT -m state --state INVALID -m limit --limit 2/s -j LOG --log-prefix "[v.$version: invalid input] "

	${iptables} -A INPUT -m state --state INVALID -j DROP

	if [ "$use_dlna" = "true" ] ; then

		# No restriction onto source IP except local network:
		${iptables} -A INPUT -p tcp -m tcp -s 10.0.0.0/16 --dport ${dlna_http_port} -j ACCEPT
		#${iptables} -A INPUT -p udp -m udp -s 10.0.0.0/16 --dport ${dlna_http_port} -j ACCEPT

		# For remote discovery (quicker than having the client wait for any
		# periodic hello from this host):
		${iptables} -A INPUT -p udp -m udp -s 10.0.0.0/16 --dport 1900 -j ACCEPT

		# IGMP broadcast:
		${iptables} -A INPUT -s 0.0.0.0/32 -d 224.0.0.1/32 -p igmp -j ACCEPT
		${iptables} -A INPUT -d 239.0.0.0/8 -p igmp -j ACCEPT

	fi

	# Filter out broadcasts:
	${iptables} -A INPUT -m pkttype --pkt-type broadcast -j DROP

	# Avoid stealth TCP port scans if SYN is not set properly:
	${iptables} -A INPUT -m state --state NEW,RELATED -p tcp ! --tcp-flags ALL SYN -j DROP

	# Rejects directly 'auth/ident' obsolete requests:
	${iptables} -A INPUT -p tcp --dport auth -j REJECT --reject-with tcp-reset

	${iptables} -A INPUT -m state --state ESTABLISHED,RELATED -j ACCEPT

	if [ $filter_epmd -eq 1 ] ; then

		$echo " - enabling EPMD at TCP port ${epmd_port}"
		${iptables} -A INPUT -p tcp --dport ${epmd_port} -m state --state NEW,ESTABLISHED,RELATED -j ACCEPT

	fi


	if [ $enable_unfiltered_tcp_range -eq 0 ] ; then

		$echo " - enabling TCP port range from ${tcp_unfiltered_low_port} to ${tcp_unfiltered_high_port}"
		${iptables} -A INPUT -p tcp --dport ${tcp_unfiltered_low_port}:${tcp_unfiltered_high_port} -m state --state NEW,ESTABLISHED,RELATED -j ACCEPT

	fi



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
	#${iptables} -A INPUT -p tcp --dport 80 -m state --state NEW -j ACCEPT

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


	## SSH:

	# One may use a non-standard port:
	#ssh_port=22
	ssh_port=44324

	# This rules allow to prevent brute-force SSH attacks by limiting the
	# frequency of attempts coming from the LAN if compromised:

	# Logs too frequent attempts tagged with 'SSH' and drops them:
	${iptables} -A INPUT -i ${lan_if} -p tcp --dport ${ssh_port} -m recent --update --seconds 60 --hitcount 4 --name SSH -j LOG --log-prefix "[v.$version: SSH brute-force] "

	${iptables} -A INPUT -i ${lan_if} -p tcp --dport ${ssh_port} -m recent --update --seconds 60 --hitcount 4 --name SSH -j DROP

	# Tags too frequent SSH attempts with the name 'SSH':
	${iptables} -A INPUT -i ${lan_if} -p tcp --dport ${ssh_port} -m recent --set --name SSH

	# Accepts nevertheless normal SSH logins:
	${iptables} -A INPUT -i ${lan_if} -p tcp --dport ${ssh_port} -j ACCEPT


	## Mail stuff:
	#${iptables} -A INPUT -p tcp --dport 25  -m state --state NEW -j ACCEPT
	#${iptables} -A INPUT -p tcp --dport 110 -m state --state NEW -j ACCEPT
	#${iptables} -A INPUT -p tcp --dport 143 -m state --state NEW -j ACCEPT
	#${iptables} -A INPUT -p tcp --dport 993 -m state --state NEW -j ACCEPT
	#${iptables} -A INPUT -p tcp --dport 995 -m state --state NEW -j ACCEPT



	## LOOPBACK
	# Allow unlimited traffic on the loopback interface.
	# e.g. needed for KDE, Gnome
	${iptables} -A INPUT -i  lo -j ACCEPT
	${iptables} -A OUTPUT -o lo -j ACCEPT


	# ---------------- ICMP ---------------------

	# Everybody from the LAN can ping me:
	# Remove that line if no one should be able to ping you
	${iptables} -A INPUT -i ${lan_if} -p icmp --icmp-type ping -j ACCEPT


	 # ---------------- LOGGING -------------------

	# Log everything else, up to 2 pings per min:
	#
	# (might be too verbose)
	#
	${iptables} -A INPUT -m limit --limit 2/minute -j LOG

	$echo "Set rules are:" >> $log_file
	${iptables} -nvL --line-numbers >> $log_file
	$echo "# ---- End of LAN rules, on $(date)." >> $log_file

}


shut_it_down()
{

	# Not only one may end up not being protected, but one may also be locked
	# out of the gateway if this command is issued remotely, e.g. through SSH,
	# whose connection will be lost after this call, preventing from restarting
	# the service again...

	$echo "Disabling LAN box firewall rules, version $version."

	# Load appropriate modules:
	${modprobe} ip_tables

	# We remove all rules and pre-exisiting user defined chains and zero the
	# counters:
	${iptables} -F
	${iptables} -X
	${iptables} -Z

	${iptables} -F -t nat
	${iptables} -X -t nat
	${iptables} -Z -t nat

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
	echo "(reloading)"
	shut_it_down
	start_it_up
  ;;
  restart)
	echo "(restarting)"
	# Note: at least in general, using the 'restart' option will not break a
	# remote SSH connection issuing that command.
	#
	shut_it_down
	start_it_up
  ;;
  status)
	echo "(status)"
	${iptables} -L
  ;;
  disable)
	echo "Disabling all rules (hence disabling the firewall)"
	${iptables} -F INPUT
	${iptables} -P INPUT ACCEPT

	${iptables} -F FORWARD
	${iptables} -P FORWARD ACCEPT

	${iptables} -F OUTPUT
	${iptables} -P OUTPUT ACCEPT
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
