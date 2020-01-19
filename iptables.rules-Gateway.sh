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


# This script configures the firewall for a gateway (ex: between an ADSL or
# optic fiber connection providing an Internet connection and the LAN).
#
# The "DMZ" corresponds here to the link between the Gateway and the Internet
# device (ex: telecom set-top box):
#
# Client computer - (LAN) - Gateway - (DMZ) - Internet device - (Internet)


# Design rules:
#
# The general approach here is based on whitelisting: by default everything is
# rejected, then only specific elements are allowed.
#
# More precisely:
# - trust the LAN: allow outgoing traffic, provided in its initiated internally
# - distrust the Internet: by default, block new incoming traffic
# - prefer droping packets to rejecting them (less information given)
#
# As a consequence, unless specified otherwise (thanks to a specific rule), a
# program running on the gateway (ex: BEAM or EPMD) will be able to send data to
# whomever it wants on the Internet and receive answers, yet *not* be able to
# listen to incoming traffic as it will receive none (since that inbound new
# traffic will be blocked).



# Original version written by Robert Penz (robert.penz@outertech.com).
# This script is under GPL.

# Adapted from GNU Linux Magazine France, number 83 (may 2006), p.14 (article
# written by Christophe Grenier, grenier@cgsecurity.org)


# For older distributions, this script is meant to be copied in /etc/init.d, to
# be set as executable, and to be registered for future automatic launches by
# using: 'update-rc.d iptables.rules-Gateway defaults' (better than being
# directly set as the target of a symbolic link in: cd /etc/rc2.d && ln -s
# ../init.d/iptables.rules-Gateway.sh).
#
# Most current distributions rely on Systemd now.
#
# Adapted for Arch Linux and Systemd (see
# https://wiki.archlinux.org/index.php/Iptables).


# To use it in the context of Arch Linux (first method, deprecated in favor of
# the next one):
#
#  - test it with the automatic support disabled: 'systemctl stop iptables'
#
#  - run this script as root, with: ./iptables.rules-Gateway.sh restart
#
#  - copy the resulting state of iptables in the relevant file ('|' used to
#    overwrite any pre-existing file):
#       iptables-save >| /etc/iptables/iptables.rules
#
#  - starts the firewall: systemctl start iptables
#
#  - check it just for this session: iptables -L
#
#  - check that iptables is meant to be started at boot:
#        systemctl is-enabled iptables.service
#      if not, run: systemctl enable iptables.service


# An alternate, preferred method is to rely on a
# /etc/systemd/system/iptables.rules-Gateway.service file, which is to recreate
# from scratch (based on code rather than data) the targeted rules.
#
# Check (including regarding the rules version) with:
#    systemctl is-enabled iptables.rules-Gateway.service
# and
#    systemctl status iptables.rules-Gateway.service


# Modprobe notes: if 'modprobe iptables' fails because of some tables not being
# found, it is the sign that the corresponding kernel modules could not be
# loaded. This often happens when the kernel modules on disk have been already
# updated while the currently running kernel, dating from latest boot, is
# lingering behind. Solution: rebooting and ensuring that these kernel modules
# are loaded at boot (see /etc/modules-load.d/ for that).


# Note: for IPv6, use 'ip6tables' instead of 'iptables'.

# A 'logdrop' rule could be defined.

# To debug more easily, by printing each line being executed first:
#set -x

# Or:
# sh -x /path/to/this/file

# Causes the script to exit on error as soon as a command failed.
# Disabled, as some commands may fail (ex: modprobe)
#set -e


if [ ! $(id -u) -eq 0 ] ; then

	echo "  Error, firewall rules can only be applied by root." 1>&2

	exit 10

fi


# Not used anymore by distros like Arch:
init_file="/lib/lsb/init-functions"

if [ -f "$init_file" ] ; then
	. "$init_file"
fi



# Useful with iptables --list|grep '\[v' or iptables -L -n |grep '\[v' to check
# whether rules are up-to-date.
#
# One may also use: 'journalctl -kf' to monitor live the corresponding kernel
# logs.
#
# 's' is for server (log prefix must be shorter than 29 characters):
#
version="s-19"



# Full path of the programs we need, change them to your needs:
iptables=/sbin/iptables
modprobe=/sbin/modprobe
echo=/bin/echo
lsmod=/sbin/lsmod
rmmod=/sbin/rmmod

log_file=/root/.lastly-gateway-firewalled.touched


# Local (LAN) interface, the one we trust:
#lan_if=eth1
lan_if=enp2s0


# Internet (WAN) interface, the one we distrust:

# For PPP ADSL connections:
#net_if=ppp0

# For direct connection to a set-top (telecom) box from your provider:
#net_if=eth0
net_if=enp4s0


# IP of a test client (to avoid too many logs, selecting only related events):
#test_client_ip="xxx"


# Tells whether Orge traffic should be allowed:
enable_orge=false

# Tells whether IPTV (TV on the Internet thanks to a box) should be allowed:
enable_iptv=false


# Tells whether a SMTP server can be used:
enable_smtp=false


# Typically a set-top box from one's ISP (defined as a possibly log match
# criteria):

# Classical example:
#telecom_box="192.168.1.254"

# Pseudo-public (actually intercepted by the Freebox, and directed to
# itself, remaining purely local):
#
#telecom_box="212.27.38.253"


start_it_up()
{

	$echo "Setting Gateway firewall rules, version $version."
	$echo "# ---- Setting Gateway firewall rules, version $version, on $(date)." > $log_file

	# Only needed for older distros that do load ipchains by default, just
	# unload it:
	#
	#if $lsmod 2>/dev/null | grep -q ipchains ; then
	#	$rmmod ipchains
	#fi

	# Note: see modprobe notes above.

	# Load appropriate modules:
	${modprobe} ip_tables 2>/dev/null

	# So that filtering rules can be commented:
	${modprobe} xt_comment 2>/dev/null

	# We load these modules as we want to do stateful firewalling:
	${modprobe} ip_conntrack 2>/dev/null
	#${modprobe} ip_conntrack_ftp 2>/dev/null
	#${modprobe} ip_conntrack_irc 2>/dev/null

	# Starts by disabling IP forwarding:
	$echo "0" > /proc/sys/net/ipv4/ip_forward

	# These lines are here in case rules are already in place and the script is
	# ever rerun on the fly.
	#
	# We want to remove all rules and pre-exisiting user defined chains, and to
	# zero the counters before we implement new rules:
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
	# There is no period, however small, when packets that we do not want are
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
	#
	$echo "0" > /proc/sys/net/ipv4/icmp_echo_ignore_all

	# Disable response to broadcasts.
	# You do not want yourself becoming a Smurf amplifier:
	#
	$echo "1" > /proc/sys/net/ipv4/icmp_echo_ignore_broadcasts

	# Do not accept source routed packets.
	#
	# Attackers can use source routing to generate traffic pretending to be from
	# inside your network, but which is routed back along the path from which it
	# came, namely outside, so attackers can compromise your network. Source
	# routing is rarely used for legitimate purposes:
	#
	$echo "0" > /proc/sys/net/ipv4/conf/all/accept_source_route

	# Disable ICMP redirect acceptance. ICMP redirects can be used to alter your
	# routing tables, possibly to a bad end:
	#
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
	# Note: if you turn on IP forwarding, you will also get this.
	#
	for interface in /proc/sys/net/ipv4/conf/*/rp_filter; do
		$echo "1" > ${interface}
	done


	# Log spoofed packets, source routed packets, redirect packets:
	#
	# (note: adding a specific rejection rule for a martian source will not
	# prevent it to be logged in the journal)
	#
	#$echo "0" > /proc/sys/net/ipv4/conf/all/log_martians

	# Finally, make sure that IP forwarding is turned on, as it is a gateway:
	$echo "1" > /proc/sys/net/ipv4/ip_forward


	## ============================================================
	# RULES


	# ---------------- DEBUG BASED ON LOGS -------------------

	# These log rules will not affect the destiny of any packet:

	# All interfaces, all states:
	#${iptables} -A FORWARD -p tcp --dport 80 -s ${test_client_ip} -j LOG --log-prefix "[FW-FWD-O] "
	#${iptables} -A FORWARD -p tcp --sport 80 -d ${test_client_ip} -j LOG --log-prefix "[FW-FWD-I] "

	# All interfaces, all states:
	#${iptables} -A OUTPUT -p tcp --dport 80 -s ${test_client_ip} -j LOG --log-prefix "[FW-OUT-O] "
	#${iptables} -A OUTPUT -p tcp --sport 80 -d ${test_client_ip} -j LOG --log-prefix "[FW-OUT-I] "

	# All interfaces, all states:
	#${iptables} -A INPUT -p tcp --dport 80 -s ${test_client_ip} -j LOG --log-prefix "[FW-IN-O] "
	#${iptables} -A INPUT -p tcp --sport 80 -d ${test_client_ip} -j LOG --log-prefix "[FW-IN-I] "



	# ---------------- PRIVACY  -------------------

	# This is an exception section, having mixed INPUT and OUTPUT rules.
	# It shall come first!

	use_ban_rules="true"
	#use_ban_rules="false"

	ban_file="/etc/ban-rules.iptables"

	if [ "$use_ban_rules" = "true" ] ; then

		if [ -f "${ban_file}" ] ; then

			$echo "Adding ban rules from '${ban_file}'."

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


	# ----------------  FORWARD ---------------------

	${iptables} -A FORWARD -p tcp --dport 80 -m state --state NEW,ESTABLISHED -j ACCEPT

	# To inspect the exchanges made by a (in-LAN) multimedia box with following
	# statically-assigned IP:
	#
	#multimedia_box=10.0.100.1

	#${iptables} -A FORWARD -i ${lan_if} -o ${net_if} -s ${multimedia_box} -j LOG --log-prefix "[FW-Box-out] "
	#${iptables} -A FORWARD -i ${net_if} -o ${lan_if} -d ${multimedia_box} -j LOG --log-prefix "[FW-Box-in]"

	if [ "$enable_iptv" = "true" ] ; then

		# So that the ISP content servers can join the LAN in terms of
		# multicast:

		# Too broad authorisation:
		#${iptables} -A FORWARD -d 224.0.0.0/4 -j ACCEPT

		# Better targeted ones; must comply with the altnet clauses in
		# /etc/igmpproxy.conf:

		${iptables} -A FORWARD -i ${net_if} -s 89.86.0.0/16    -d 224.0.0.0/4 -j ACCEPT
		${iptables} -A FORWARD -i ${net_if} -s 193.251.97.0/24 -d 224.0.0.0/4 -j ACCEPT

	fi

	## We are masquerading the full LAN:
	${iptables} -t nat -A POSTROUTING -o ${net_if} -s 10.0.0.0/8 -j MASQUERADE

	# NAT reduces the MTU, so counter-measure:
	${iptables} -A FORWARD -p tcp --tcp-flags SYN,RST SYN -j TCPMSS -o ${net_if} --clamp-mss-to-pmtu

	# Only forward that stuff from one interface to the other, and do that with
	# connection tracking:

	# Everything from the LAN interface to the Internet one is forwarded:
	${iptables} -A FORWARD -i ${lan_if} -o ${net_if} -m state --state NEW,ESTABLISHED,RELATED -j ACCEPT

	# Packets from the Internet interface to the LAN one must not be new unknown
	# connections:
	#
	${iptables} -A FORWARD -i ${net_if} -o ${lan_if} -m state --state ESTABLISHED,RELATED -j ACCEPT


	#AD_FILTER_PORT=3129
	## Transparent proxy
	#
	# Redirects http traffic to port $AD_FILTER_PORT where our ad filter is
	# running. Normal squid port is 3128.
	#
	#${iptables} -t nat -A PREROUTING -i ${lan_if} -p tcp --dport 80 -j REDIRECT --to-port ${AD_FILTER_PORT}

	# To access from the LAN  (ex: a multimedia box, or a local computer
	# to tune the telecom box) to a telecom box with such IP (may be superfluous):
	#
	#${iptables} -A FORWARD -i ${lan_if} -o ${net_if} -d ${telecom_box} -j ACCEPT



	# ----------------  OUTPUT ---------------------

	# To allow packets from the gateway to reach that telecom box:
	#${iptables} -A OUTPUT -o ${net_if} -d ${telecom_box} -j ACCEPT

	# No unroutable (private) adddress should be output by the gateway:
	${iptables} -A OUTPUT -o ${net_if} -d 10.0.0.0/8     -j REJECT
	${iptables} -A OUTPUT -o ${net_if} -d 127.0.0.0/8    -j REJECT
	${iptables} -A OUTPUT -o ${net_if} -d 172.16.0.0/12  -j REJECT

	# Now the DMZ is 192.168.0.0/16, so we cannot reject anymore with:
	#${iptables} -A OUTPUT -o ${net_if} -d 192.168.0.0/16 -j REJECT


	# Protect the LAN:
	${iptables} -A OUTPUT -o ${lan_if} -d 192.168.0.0/16 -j REJECT

	# Second rule is to let packets through which belong to established or
	# related connections and we let all traffic out, as we trust ourself
	# (i.e. what we run from the gateway):
	#
	${iptables} -A OUTPUT -m state --state NEW,ESTABLISHED,RELATED -j ACCEPT



	# ----------------  INPUT ---------------------

	# To log all input packets:
	#${iptables} -A INPUT -i ${net_if} -j LOG --log-prefix "[FW-all-I] "

	# Log some invalid connections:
	# (disabled, as uselessly verbose)
	#${iptables} -A INPUT -m state --state INVALID -m limit --limit 2/s -j LOG --log-prefix "[v.$version: invalid input] "

	${iptables} -A INPUT -m state --state INVALID -j DROP

	# Filter out broadcasts:
	${iptables} -A INPUT -m pkttype --pkt-type broadcast -j DROP

	if [ "$enable_iptv" = "true" ] ; then

		# Needed for the IGMP proxy, in both ways:
		${iptables} -A INPUT -d 224.0.0.0/4 -j ACCEPT

	fi


	# DHT subsection, for P2P exchanges:
	# More infos: https://github.com/rakshasa/rtorrent/wiki/Using-DHT

	dht_udp_port=7881

	#use_dht="true"
	use_dht="false"

	if [ "$use_dht" = "true" ] ; then

		${iptables} -A INPUT -i ${net_if} -p udp -m udp --dport ${dht_udp_port} -j ACCEPT

	fi

	# Drops directly connections coming from the Internet with unroutable
	# (private) addresses:
	#
	${iptables} -A INPUT -i ${net_if} -s 10.0.0.0/8     -j DROP
	${iptables} -A INPUT -i ${net_if} -s 127.0.0.0/8    -j DROP
	${iptables} -A INPUT -i ${net_if} -s 172.16.0.0/12  -j DROP


	# If the IP of the gateway interface on the DMZ is assigned by a telecom box
	# in router mode (hence IP-level, not frame-level like when in bridge mode)
	# through DHCP (for example in the 192.168.0.0/24 range, say 192.168.0.1),
	# one may would like to block incoming traffic that would originate from
	# that box.
	#
	# However this rule shall remain *deactivated*, otherwise web access to the
	# gateway public address from the LAN will fail; presumably because the
	# connection goes from the LAN client through the gateway (forward), and the
	# telecom box sees a TCP connection from its DMZ interface to its own public
	# address, which it routes back to the gateway with its own LAN address
	# (thus in 192.168.0.0/24); so we must let this traffic exist:
	#
	#${iptables} -A INPUT -i ${net_if} -s 192.168.0.0/24 -j DROP


	# Avoid stealth TCP port scans if SYN is not set properly:
	${iptables} -A INPUT -m state --state NEW,RELATED -p tcp ! --tcp-flags ALL SYN -j DROP

	# Rejects directly 'auth/ident' obsolete requests:
	${iptables} -A INPUT -p tcp --dport auth -j REJECT --reject-with tcp-reset

	# Accept non-new inputs:
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
	#
	${iptables} -A INPUT -f -j LOG --log-prefix "[v.$version: fragments] "
	${iptables} -A INPUT -f -j DROP

	# HTTP (for webservers):
	${iptables} -A INPUT -p tcp --dport 80 -m state --state NEW,ESTABLISHED -j ACCEPT

	# HTTPS (for webservers as well):
	${iptables} -A INPUT -p tcp --dport 443 -m state --state NEW,ESTABLISHED -j ACCEPT

	## ident, if we drop these packets we may need to wait for the timeouts
	# e.g. on ftp servers:
	#
	${iptables} -A INPUT -p tcp --dport 113 -m state --state NEW -j REJECT

	## FTP:
	# (not used anymore - prefer SFTP, hence on the same port as SSH, instead)
	#
	#${iptables} -A INPUT -p tcp --dport 20 -m state --state NEW -j ACCEPT
	#${iptables} -A INPUT -p tcp --dport 21 -m state --state NEW -j ACCEPT


	# Orge section:

	# Erlang default:
	default_epmd_port=4369

	orge_epmd_port=4506

	if [ "$enable_orge" = "true" ] ; then

		# For Erlang epmd daemon (allowing that would be a *major* security hazard):

		#${iptables} -A INPUT -p tcp --dport ${orge_epmd_port} -m state --state NEW -j ACCEPT

		# For the listening socket of TCP Orge server:
		${iptables} -A INPUT -p tcp --dport 9512 -m state --state NEW -j ACCEPT

		# For any passive FTP and client TCP Orge server sockets:
		${iptables} -A INPUT -p tcp --dport 51000:51999 -m state --state NEW,ESTABLISHED,RELATED -j ACCEPT

		# For the main UDP Orge server socket:
		${iptables} -A INPUT -p udp --dport 9512 -m state --state NEW -j ACCEPT

	fi

	if [ $orge_epmd_port -eq $default_epmd_port ]; then

		echo "Warning: Orge using the default Erlang EPMD port ($default_epmd_port), this is strongly discouraged." 1>&2

	else

		# We explicitly filter out the *default* EPMD port, on the WAN interface
		# only (still wanting to be able to launch named nodes from that
		# gateway), to avoid any security hazard at this level:
		#
		${iptables} -A INPUT -i ${net_if} -p tcp --dport $default_epmd_port -j REJECT

		# For any additional safety thereof:
		${iptables} -A INPUT -i ${net_if} -p tcp --dport $orge_epmd_port -j REJECT

	fi


	## SSH:

	# One may use a non-standard port:
	#ssh_port=22
	ssh_port=44324

	# Unlimited input from LAN (trying to resist any loss of connection/firewall
	# reload):
	#
	${iptables} -A INPUT -i ${lan_if} -p tcp --dport ${ssh_port} -m state --state NEW,ESTABLISHED -j ACCEPT

	# These rules allow to prevent brute-force SSH attacks by limiting the
	# frequency of attempts coming from the Internet:

	# Logs too frequent attempts tagged with 'SSH' and drops them:
	${iptables} -A INPUT -i ${net_if} -p tcp --dport ${ssh_port} -m recent --update --seconds 60 --hitcount 4 --name SSH -j LOG --log-prefix "[v.$version: SSH brute-force] "

	${iptables} -A INPUT -i ${net_if} -p tcp --dport ${ssh_port} -m recent --update --seconds 60 --hitcount 4 --name SSH -j DROP

	# Tags too frequent SSH attempts with the name 'SSH':
	${iptables} -A INPUT -i ${net_if} -p tcp --dport ${ssh_port} -m recent --set --name SSH

	# Accepts nevertheless normal SSH logins:
	${iptables} -A INPUT -i ${net_if} -p tcp --dport ${ssh_port} -j ACCEPT


	## Mail stuff:

	# All mail-related ports are TCP ones.

	# Sending emails:

	smtp_port=25

	# SMTPS is obsolete:
	smtp_secure_port=465

	# STARTTLS over SMTP is the proper way of securing SMTP:
	msa_port=587

	if [ "$enable_smtp" = "true" ] ; then

		# Basic setting:

		# Allowed from all interfaces:
		${iptables} -A INPUT -p tcp --dport ${msa_port} -m state --state NEW -j ACCEPT

		# IMAP is a protocol which runs on 143 and 993 (SSL) ports

		# Ex: Dovecot:

		#${iptables} -A INPUT -p tcp --dport 143 -m state --state NEW -j ACCEPT
		#${iptables} -A INPUT -p tcp --dport 993 -m state --state NEW -j ACCEPT

		#${iptables} -A INPUT -p tcp --dport 110 -m state --state NEW -j ACCEPT
		#${iptables} -A INPUT -p tcp --dport 995 -m state --state NEW -j ACCEPT

	fi


	# Receiving emails:

	pop3_port=110

	# POP3S:
	pop3_secure_port=995

	imap_port=143
	imap_secure_port=993


	# Allow UDP & TCP packets to the DNS server from LAN clients (only needed if
	# this gateway is a LAN DNS server, for example with dnsmasq).
	#
	${iptables} -A INPUT -i ${lan_if} -p tcp --dport 53 -m state --state NEW -j ACCEPT
	${iptables} -A INPUT -i ${lan_if} -p udp --dport 53 -m state --state NEW -j ACCEPT


	# NUT, for UPS monitoring:
	${iptables} -A INPUT -i ${lan_if} -p tcp --dport 3493 -m state --state NEW -j ACCEPT
	${iptables} -A INPUT -i ${lan_if} -p udp --dport 3493 -m state --state NEW -j ACCEPT


	# Squid (only local)
	#${iptables} -A INPUT -p tcp -i ${lan_if} --dport 3128:3129 -m state --state NEW -j ACCEPT

	# Allow the smb stuff (only local)
	#${iptables} -A INPUT -i ${lan_if} -p udp --dport 137:139 -m state --state NEW -j ACCEPT
	#${iptables} -A INPUT -i ${lan_if} -p tcp --dport 137:139 -m state --state NEW -j ACCEPT

	# GnomeMeeting:
	#${iptables} -A INPUT -p tcp --dport 30000:33000 -j ACCEPT
	#${iptables} -A INPUT -p tcp --dport 1720 -j ACCEPT
	#${iptables} -A INPUT -p udp --dport 5000:5006 -j ACCEPT

	## LOOPBACK

	# Allow unlimited traffic on the loopback interface, e.g. needed for KDE,
	# Gnome, etc.:
	#
	${iptables} -A INPUT  -i lo -j ACCEPT
	${iptables} -A OUTPUT -o lo -j ACCEPT


	# ---------------- ICMP ---------------------

	# Everybody from the LAN can ping me (but no one from the Internet; however
	# the network box may answer instead):
	#
	# Comment that line if no one should be able to ping you from the LAN:
	${iptables} -A INPUT -i ${lan_if} -p icmp --icmp-type ping -j ACCEPT

	# No Internet ping:
	${iptables} -A INPUT -i ${net_if} -p icmp --icmp-type ping -j DROP


	# ---------------- NTP ---------------------

	# Local clients can ask for gateway-synchronized time:
	${iptables} -A INPUT -i ${lan_if} -p udp --dport 123 -m state --state NEW,ESTABLISHED,RELATED -j ACCEPT


	# ---------------- LOGGING -------------------

	# Log everything else, up to 2 pings per min:
	#
	# (should be disabled if connected to the Internet, as far too verbose in
	# system logs, might hide other important events)
	#
	#${iptables} -A INPUT -m limit --limit 2/minute -j LOG


	$echo "Set rules are:" >> $log_file
	${iptables} -nvL --line-numbers >> $log_file
	$echo "# ---- End of gateway rules, on $(date)." >> $log_file

	# Not true anymore if, as recommended, using now
	# iptables.rules-Gateway.service (updating Ceylan-Hull shall be enough
	# then):
	#
	#$echo "iptables rules applied; to enforce them durably, update /etc/iptables/iptables.rules (see script comments for that)."

}


shut_it_down()
{

	# Not only one may end up not being protected, but one may also be locked
	# out of the gateway if this command is issued remotely, e.g. through SSH,
	# whose connection will be lost after this call, preventing from restarting
	# the service again...

	$echo "Disabling Gateway firewall rules (DANGER!)."

	# Load appropriate modules:
	${modprobe} ip_tables 2>/dev/null

	# We remove all rules and pre-existing user-defined chains, and zero the
	# counters before we implement new rules:
	#
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
	  echo "Warning: if this script is executed remotely (ex: through a SSH connection), stopping will isolate that host; maybe updating this script and restarting (ex: 'systemctl restart iptables.rules-Gateway.service') would be then a better solution."
	  echo "Proceed anyway? [y/n] (default: n)"
	  read answer
	  if [ "${answer}" = "y" ] ; then
		  shut_it_down
	  else
		  echo "(stop aborted)"
	  fi
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
		echo "Usage: $script_name {start|stop|reload|restart|force-reload|status|disable}" >&2

	else

		echo "Usage: /etc/init.d/$NAME {start|stop|reload|restart|force-reload|status|disable}" >&2

	fi

	exit 2

  ;;

esac

exit 0
