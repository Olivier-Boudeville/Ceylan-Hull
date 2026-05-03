#!/bin/sh

script_opts="{start|stop|reload|restart|force-reload|status|disable}"

usage="Usage: $(basename $0) ${script_opts}: manages a minimal firewall suitable for a LAN host."

# Stripped-down version of iptables.rules-LANBox.sh; refer to it for more
# details.


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



# Useful with iptables --list|grep '\[v' or iptables -nL |grep '\[v' to check
# whether rules are up-to-date.
#
# Very useful as well: 'iptables -S'.
#
# One may also use: 'journalctl -kf' to monitor live the corresponding kernel
# logs.
#
# 'cm' is for client, in its minimal version (log prefix must be shorter than 29
# characters):
#
version="cm-1"

# Logic of toggle variables: they are to be compared to "true" or "false"
# (clearer than, respectively, 0 or 1).

# Now the settings are not embedded anymore in this script, but in the next
# file, meant to be sourced:
#
setting_file="/etc/iptables.settings-LANBox.sh"


if [ ! -f "${setting_file}" ]; then

	${echo} " Error, setting file ('${setting_file}') not found." 1>&2

	exit 15

fi

. "${setting_file}"


# Defined in settings file:
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

	${echo} "No LAN interface (lan_if) set, trying to auto-detect it." >> "${log_file}"

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



# Not all settings tested.


start_it_up()
{

	${echo} "Setting LAN box minimal firewall rules, version ${version}."

	${echo} >> "${log_file}"
	${echo} "# ---- Setting LAN box minimal firewall rules, version ${version}, on $(date)." >> "${log_file}"
	${echo} >> "${log_file}"


	${echo} "Interface: LAN is ${lan_if}." >> "${log_file}"
	${echo} >> "${log_file}"
	${echo} >> "${log_file}"

	${echo} "Applying settings now:" >> "${log_file}"

	# Only needed for older distros that do load ipchains by default, just
	# unload it:
	#
	#if $lsmod 2>/dev/null | grep -q ipchains; then
	#   $rmmod ipchains
	#fi

	# Note: see modprobe notes above.

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

	# These lines are here should rules be already in place and the script be
	# run on the fly.
	#
	# We want to remove all rules and pre-existing user defined chains, and to
	# zero the counters before we implement new rules:
	#
	${iptables} -F
	${iptables} -X
	${iptables} -Z

	for table in nat mangle raw security; do
		${iptables} -F -t ${table}
		${iptables} -X -t ${table}
		${iptables} -Z -t ${table}
	done

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
	${echo} "0" > /proc/sys/net/ipv4/icmp_echo_ignore_all

	# Disable response to broadcasts.
	# You do not want yourself becoming a Smurf amplifier:
	#
	${echo} "1" > /proc/sys/net/ipv4/icmp_echo_ignore_broadcasts

	# Do not accept source routed packets.
	#
	# Attackers can use source routing to generate traffic pretending to be from
	# inside your network, but which is routed back along the path from which it
	# came, namely outside, so attackers can compromise your network. Source
	# routing is rarely used for legitimate purposes:
	#
	${echo} "0" > /proc/sys/net/ipv4/conf/all/accept_source_route

	# Disable ICMP redirect acceptance. ICMP redirects can be used to alter your
	# routing tables, possibly to a bad end:
	#
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
	# Note: if you turn on IP forwarding, you will also get this.
	#
	for interface in /proc/sys/net/ipv4/conf/*/rp_filter; do
		${echo} "1" > "${interface}"
	done


	# Log spoofed packets, source routed packets, redirect packets:
	#
	# (note: adding a specific rejection rule for a martian source will not
	# prevent it to be logged in the journal)
	#
	#${echo} "0" > /proc/sys/net/ipv4/conf/all/log_martians

	# Make sure that IP forwarding is turned off.
	#
	# We only want this for a multi-homed host.
	# Remember: this is for a LAN box (mere client)
	${echo} "0" > /proc/sys/net/ipv4/ip_forward


	## ============================================================
	# RULES


	# ----------------  No FORWARD rules here ------


	# ----------------  OUTPUT ---------------------

	## First rule is to let packets through which belong to established or
	# related connections and we let all traffic out as we trust ourself.
	${iptables} -A OUTPUT -m state --state NEW,ESTABLISHED,RELATED -j ACCEPT


	# ----------------  INPUT ---------------------

	# Log some invalid connections:
	# (disabled, as uselessly verbose)
	#${iptables} -A INPUT -m state --state INVALID -m limit --limit 2/s -j LOG --log-prefix "[v.${version}: invalid input] "

	#${iptables} -A INPUT -m state --state INVALID -j DROP

	# Filter out (other) broadcasts:
	#${iptables} -A INPUT -m pkttype --pkt-type broadcast -j DROP

	# Accept all here:
	${iptables} -A INPUT -m state --state NEW,ESTABLISHED,RELATED -j ACCEPT


	## LOOPBACK
	# Allow unlimited traffic on the loopback interface.
	# e.g. needed for KDE, Gnome
	${iptables} -A INPUT -i  lo -j ACCEPT
	${iptables} -A OUTPUT -o lo -j ACCEPT


	 # ---------------- LOGGING -------------------

	# Log everything else, up to 2 pings per min:
	#
	# (might be too verbose)
	#
	${iptables} -A INPUT -m limit --limit 2/minute -j LOG

	${echo} "Set rules are:" >> "${log_file}"
	${iptables} -nvL --line-numbers >> "${log_file}"
	${echo} >> "${log_file}"
	${echo} "# ---- End of LAN minimal rules version ${version}, on $(date)." >> "${log_file}"

}


shut_it_down()
{

	# Not only one may end up not being protected, but one may also be locked
	# out of the host if this command is issued remotely, e.g. through SSH,
	# whose connection will be lost after this call, preventing from restarting
	# the service again... So such disabling may not be a good idea.

	${echo} "Disabling LAN box minimal firewall rules, version ${version} (DANGER!)."

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
	${echo} "Warning: if this script is executed remotely (e.g. through a SSH connection), stopping will isolate that host; maybe updating this script and restarting (e.g. 'systemctl restart iptables.rules-LAN.service') would be then a better solution."
	${echo} "Proceed anyway? [y/n] (default: n)"
	read answer
	if [ "${answer}" = "y" ]; then
		shut_it_down
	else
		${echo} "(stop aborted)"
	fi
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

		# Obsolete:
		${echo} "Usage: /etc/init.d/${NAME} ${script_opts}" >&2

	fi

	exit 2

  ;;

esac

${echo}
${echo} "The content of log file ('${log_file}') follows:"
/bin/cat "${log_file}"

exit 0
