#!/bin/sh

script_opts="{start|stop|reload|restart|force-reload|status|disable}"

usage="Usage: $(basename $0) ${script_opts}: manages a well-configured firewall suitable for a LAN host."


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

# Original version Written by Robert Penz (robert.penz@outertech.com).
# This script is under GPL.

# Adapted from GNU Linux Magazine France, number 83 (may 2006), p.14
# (article written by Christophe Grenier, grenier@cgsecurity.org)


# For older distributions, this script is meant to be copied in /etc/init.d, to
# be set as executable, and to be registered for future automatic launches by
# using: 'update-rc.d iptables.rules-LANBox defaults' (better than being
# directly set as the target of a symbolic link in: cd /etc/rc2.d && ln -s
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
# Current approach is using a simple systemd unit that we wrote,
# i.e. /etc/systemd/system/iptables.rules-LAN.service.
#
# Check its actual support with 'systemctl is-enabled
# iptables.rules-LAN.service' (should return 'enabled'); then run 'systemctl
# restart iptables.rules-LAN.service ; systemctl status
# iptables.rules-LAN.service' to check.
#
#
# Former approach was using the 'iptables' systemd built-in *service* (now not
# enabled anymore):
#
#  - run this script as root, with: 'iptables.rules-LANBox.sh start'
#
#  - copy the resulting state of iptables in the relevant file (note: this
# filename cannot be changed, it is a system convention):
#   'iptables-save > /etc/iptables/iptables.rules'
#
#  - restart the firewall: 'systemctl restart iptables ; systemctl status
#  iptables'
#
#  - check it just for this session: 'iptables -L' (can any changes be found?)
#
#  - check that iptables is meant to be started at boot:
#  'systemctl is-enabled iptables.service'; if not, run:
# 'systemctl enable iptables.service'


# Note: for IPv6, use 'ip6tables' instead of 'iptables'.

# A 'logdrop' rule could be defined.

# To debug more easily, by printing each line being executed first:
#set -x

# Or:
# sh -x /path/to/this/file

# Causes the script to exit on error as soon as a command failed.
# Disabled, as some commands may fail (ex: modprobe)
#set -e


# Full path of the programs we need, change them to your needs:
iptables="/sbin/iptables"
modprobe="/sbin/modprobe"
echo="/bin/echo"
lsmod="/sbin/lsmod"
rmmod="/sbin/rmmod"


if [ ! $(id -u) -eq 0 ]; then

	${echo} "  Error, firewall rules can only be applied by root." 1>&2

	exit 10

fi


# Not used anymore by distros like Arch:
#init_file="/lib/lsb/init-functions"

#if [ -f "${init_file}" ]; then
#	. "${init_file}"
#fi



# Useful with iptables --list|grep '\[v' or iptables -L -n |grep '\[v' to check
# whether rules are up-to-date.
#
# One may also use: 'journalctl -kf' to monitor live the corresponding kernel
# logs.
#
# 'c' is for client (log prefix must be shorter than 29 characters):
#
version="c-13"


# Now the settings are not embedded anymore in this script, but in the next
# file, meant to be sourced:
#
setting_file="/etc/iptables.settings-LANBox.sh"


if [ ! -f "${setting_file}" ]; then

	${echo} " Error, setting file ('${setting_file}') not found." 1>&2

	exit 15

fi


# Logic of toggle variables: they are to be compared to "true" or "false"
# (clearer than, respectively, 0 or 1).

. "${setting_file}"


if [ -z "${log_file}" ]; then

	${echo} " Error, log_file not defined." 1>&2

	exit 16

fi


if [ -f "${log_file}" ]; then

	/bin/rm -f "${log_file}"

fi


# From now on, log-related echos can be done in the log file:
${echo} > "${log_file}"


if [ -z "${lan_if}" ]; then

	${echo} "No LAN interface set, trying to auto-detect it." >> "${log_file}"

	detected_if="$(ip link | grep ': <' | sed 's|: <.*$||' | cut -d ' ' -f 2 | grep -v '^lo$')"

	if [ -z "${detected_if}" ]; then

		${echo} "  No LAN interface found!" 1>&2
		exit 25

	fi

	printf "* detected network interfaces: \n${detected_if}" >> "${log_file}"
	${echo}

	# By default we select the first interface found:
	lan_if="$(${echo} ${detected_if} | sed 's| .*$||1')"

	${echo} >> "${log_file}"
	${echo} >> "${log_file}"
	${echo} "* selected LAN interface: ${lan_if}" >> "${log_file}"

	if [ -z "${lan_if}" ]; then

		${echo} "  No LAN interface selected!" 1>&2
		exit 30

	fi

else

	${echo} "Using specified LAN interface ${lan_if}." >> "${log_file}"

fi


if [ -z "${ssh_port}" ]; then

	${echo} " Error, ssh_port not defined." 1>&2

	exit 22

fi


# Not all settings tested.




start_it_up()
{

	${echo} "Setting LAN box firewall rules, version $version."

	${echo} >> "${log_file}"
	${echo} "# ---- Setting LAN firewall rules, version $version, on $(date)." >> "${log_file}"
	${echo} >> "${log_file}"


	${echo} "Interface: LAN is ${lan_if}." >> "${log_file}"
	${echo} "Services: EPMD is '${allow_epmd}' (port: ${epmd_port}), TCP filter range is '${enable_unfiltered_tcp_range}' (range: ${tcp_unfiltered_low_port}:${tcp_unfiltered_high_port}), RTSP is '${allow_rtsp}', SSH port is '${ssh_port}', ban rules is '${use_ban_rules}' (file: ${ban_file})." >> "${log_file}"

	# Only needed for older distros that do load ipchains by default, just
	# unload it:
	#
	#if $lsmod  2>/dev/null | grep -q ipchains; then
	#	$rmmod ipchains
	#fi

	# Load appropriate modules:
	#
	# (was commented-out: this (correct) call returned an error and used to
	# cause the script to silently abort)
	#
	${modprobe} ip_tables 2>/dev/null

	# So that filtering rules can be commented:
	${modprobe} xt_comment 2>/dev/null

	# Not necessary to be able to use continuous port range:
	#${modprobe} xt_multiport 2>/dev/null

	# These lines are here in case rules are already in place and the script is
	# ever rerun on the fly.
	#
	# We want to remove all rules and pre-existing user defined chains, and to
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
	${echo} "0" > /proc/sys/net/ipv4/icmp_echo_ignore_all

	# Disable response to broadcasts.
	# You do not want yourself becoming a Smurf amplifier:
	${echo} "1" > /proc/sys/net/ipv4/icmp_echo_ignore_broadcasts

	# Do not accept source routed packets.
	#
	# Attackers can use source routing to generate traffic pretending to be from
	# inside your network, but which is routed back along the path from which it
	# came, namely outside, so attackers can compromise your network. Source
	# routing is rarely used for legitimate purposes:
	${echo} "0" > /proc/sys/net/ipv4/conf/all/accept_source_route

	# Disable ICMP redirect acceptance. ICMP redirects can be used to alter your
	# routing tables, possibly to a bad end:
	${echo} "0" > /proc/sys/net/ipv4/conf/all/accept_redirects

	# Enable bad error message protection:
	${echo} "1" > /proc/sys/net/ipv4/icmp_ignore_bogus_error_responses

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
		${echo} "1" > ${interface}
	done

	# Log spoofed packets, source routed packets, redirect packets:
	${echo} "1" > /proc/sys/net/ipv4/conf/all/log_martians

	# Make sure that IP forwarding is turned off.
	#
	# We only want this for a multi-homed host.
	# Remember: this is for a LAN box (mere client)
	${echo} "0" > /proc/sys/net/ipv4/ip_forward


	## ============================================================
	# RULES

	# ---------------- PRIVACY  -------------------

	# This is an exception section, having mixed INPUT and OUTPUT rules.
	# It shall come first!

	if [ "$use_ban_rules" = "true" ]; then

		if [ -f "${ban_file}" ]; then

			${echo} " - adding ban rules from '${ban_file}'" >> "${log_file}"

			# May add useless FORWARD rules as well (expected to be harmless):
			. "${ban_file}"

			res=$?

			if [ ! $res -eq 0 ]; then

				${echo} "  Error, the addition of ban rules failed." 1>&2

				exit 60

			fi

		else

			${echo} "  Error, ban rules enabled, yet ban file (${ban_file}) not found." 1>&2

			exit 61

		fi

	fi

	# ----------------  No FORWARD rules here ------


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

	if [ "$allow_dlna" = "true" ]; then

		${echo} " - enabling UPnP/DLNA service at TCP port ${trivnet1_tcp_port} and UDP port ${ssdp_udp_port}" >> "${log_file}"

		# No restriction onto source IP except local network:
		${iptables} -A INPUT -p tcp -m tcp -s 10.0.0.0/16 --dport ${trivnet1_tcp_port} -j ACCEPT

		${iptables} -A INPUT -p udp -m udp -s 10.0.0.0/16 --dport ${ssdp_udp_port} -j ACCEPT

		# IGMP broadcast, apparently useless here:
		#${iptables} -A INPUT -s 0.0.0.0/32 -d 224.0.0.1/32 -p igmp -j ACCEPT
		#${iptables} -A INPUT -d 239.0.0.0/8 -p igmp -j ACCEPT

	fi


	if [ "$allow_rtsp" = "true" ]; then

		${echo} " - enabling RTSP/RTP service at UDP port ${live555_udp_port}" >> "${log_file}"

		# Thought that was needed, but apparently not:
		#${iptables} -A INPUT -p udp -m udp -s ${rtsp_server} -j ACCEPT

		# Note: live555 must be sending a broadcast packet, with no specific
		# emitter, so adding '-s ${rtsp_server}' would disallow the right
		# packet(s) to be received:
		#
		${iptables} -A INPUT -p udp -m udp --dport ${live555_udp_port} -j ACCEPT

	fi


	# Filter out (other) broadcasts:
	${iptables} -A INPUT -m pkttype --pkt-type broadcast -j DROP

	# Avoid stealth TCP port scans if SYN is not set properly:
	${iptables} -A INPUT -m state --state NEW,RELATED -p tcp ! --tcp-flags ALL SYN -j DROP

	# Rejects directly 'auth/ident' obsolete requests:
	${iptables} -A INPUT -p tcp --dport auth -j REJECT --reject-with tcp-reset

	${iptables} -A INPUT -m state --state ESTABLISHED,RELATED -j ACCEPT

	if [ "${allow_epmd}" = "true" ]; then

		${echo} " - enabling EPMD at TCP port ${epmd_port}" >> "${log_file}"
		${iptables} -A INPUT -p tcp --dport ${epmd_port} -m state --state NEW,ESTABLISHED,RELATED -j ACCEPT

	fi


	if [ "$enable_unfiltered_tcp_range" = "true" ]; then

		${echo} " - enabling TCP port range from ${tcp_unfiltered_low_port} to ${tcp_unfiltered_high_port}" >> "${log_file}"
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

	# This rules allow to prevent brute-force SSH attacks by limiting the
	# frequency of attempts coming from the LAN if compromised:

	# Logs too frequent attempts tagged with 'SSH' and drops them if requested:
	${iptables} -A INPUT -i ${lan_if} -p tcp --dport ${ssh_port} -m recent --update --seconds 60 --hitcount 4 --name SSH -j LOG --log-prefix "[v.$version: SSH brute-force] "

	if [ "${limit_ssh_connection_rate}" = "true" ]; then

		${iptables} -A INPUT -i ${lan_if} -p tcp --dport ${ssh_port} -m recent --update --seconds 60 --hitcount 4 --name SSH -j DROP

	fi

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

	${echo} "Set rules are:" >> "${log_file}"
	${iptables} -nvL --line-numbers >> "${log_file}"
	${echo} "# ---- End of LAN rules, on $(date)." >> "${log_file}"

}


shut_it_down()
{

	# Not only one may end up not being protected, but one may also be locked
	# out of the gateway if this command is issued remotely, e.g. through SSH,
	# whose connection will be lost after this call, preventing from restarting
	# the service again...

	${echo} "Disabling LAN box firewall rules, version ${version}."

	# Load appropriate modules:
	${modprobe} ip_tables 2>/dev/null

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
	${echo} "(reloading)"
	shut_it_down
	start_it_up
	;;

  restart)
	${echo} "(restarting)"
	# Note: at least in general, using the 'restart' option will not break a
	# remote SSH connection issuing that command.
	#
	shut_it_down
	start_it_up
	;;

  status)
	${echo} "(status)"
	${iptables} -L
	;;

  disable)
	${echo} "Disabling all rules (hence disabling the firewall)"
	${iptables} -F INPUT
	${iptables} -P INPUT ACCEPT

	${iptables} -F FORWARD
	${iptables} -P FORWARD ACCEPT

	${iptables} -F OUTPUT
	${iptables} -P OUTPUT ACCEPT
	;;

  *)
	${echo} >&2
	${echo} " Error, no appropriate action specified." >&2

	if [ -z "${NAME}" ]; then
		# Launched from the command-line:
		${echo} "${usage}" >&2

	else

		${echo} "${usage}" >&2

	fi

	exit 2

  ;;

esac

${echo}
${echo} "The content of log file ('${log_file}') follows:"
/bin/cat "${log_file}"

exit 0
