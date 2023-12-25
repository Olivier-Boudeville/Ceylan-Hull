#!/bin/sh

script_opts="{start|stop|reload|restart|force-reload|status|disable}"

usage="Usage: $(basename $0) ${script_opts}: sets up a minimal yet functional firewall suitable for a gateway host with masquerading and as few services as possible."


# Note: this script can be safely run remotely from within the LAN whereas a
# usual gateway configuration is enforced and SSH connections are active, as
# accesses (web and SSH) will remain available (hence no need to rush to the
# gateway itself to fix a network issue is expected to happen).


# This script configures the firewall for a minimal gateway, so that traffic is
# still routed yet no fancy rules are applied, except masquerading and extensive
# logging; it is convenient, in case of trouble (e.g. with hosted webservers),
# in order to test whether the firewall interferes.

# Full path of the programs we need, change them to your needs:
iptables=/sbin/iptables
modprobe=/sbin/modprobe
echo=/bin/echo
lsmod=/sbin/lsmod
rmmod=/sbin/rmmod


if [ ! $(id -u) -eq 0 ]; then

	$echo "  Error, firewall rules can only be applied by root." 1>&2

	exit 10

fi


# Useful with iptables --list|grep '\[v' or iptables -L -n |grep '\[v' to check
# whether rules are up-to-date.
# 's' is for server (log prefix must be shorter than 29 characters):
#
# Useful with iptables --list|grep '\[v' or iptables -L -n |grep '\[v' to check
# whether rules are up-to-date.
#
# One may also use: 'journalctl -kf' to monitor live the corresponding kernel
# logs.
#
# 's' is for server (log prefix must be shorter than 29 characters):
#
version="s-test-2"



# Now the settings are not embedded anymore in this script, but in the next
# file, meant to be sourced:
#
setting_file="/etc/iptables.settings-Gateway.sh"


if [ ! -f "${setting_file}" ]; then

	$echo " Error, setting file ('${setting_file}) not found." 1>&2

	exit 15

fi


# Logic of toggle variables: they are to be compared to "true" or "false"
# (clearer than, respectively, 0 or 1).

. "${setting_file}"


if [ -z "${log_file}" ]; then

	$echo " Error, log_file not defined." 1>&2

	exit 16

fi


if [ -f "${log_file}" ]; then

	/bin/rm -f "${log_file}"

fi


# From now on, log-related echos can be done in the log file:
$echo > "${log_file}"


if [ -z "${lan_if}" ]; then

	$echo " Error, lan_if not defined." 1>&2

	exit 17

fi


if [ -z "${net_if}" ]; then

	$echo " Error, net_if not defined." 1>&2

	exit 18

fi


if [ -z "${enable_orge}" ]; then

	$echo " Error, enable_orge not defined." 1>&2

	exit 19

fi


if [ -z "${enable_iptv}" ]; then

	$echo " Error, enable_iptv not defined." 1>&2

	exit 20

fi


if [ -z "${enable_smtp}" ]; then

	$echo " Error, enable_smtp not defined." 1>&2

	exit 21

fi


if [ -z "${ssh_port}" ]; then

	$echo " Error, ssh_port not defined." 1>&2

	exit 22

fi


# Not all settings tested.


# Not a parameter:

# Erlang default:
default_epmd_port=4369



# The general approach here is based on whitelisting: by default everything is
# rejected, then only specific elements are allowed.

start_it_up()
{

	$echo "Setting Minimal gateway firewall rules, version $version."

	$echo >> "${log_file}"
	$echo "# ---- Setting Minimal gateway firewall rules, version $version, on $(date)." >> "${log_file}"
	$echo >> "${log_file}"


	$echo "Interfaces: LAN is ${lan_if}, Internet is ${net_if}." >> "${log_file}"

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
	# We want to remove all rules and pre-existing user defined chains, and to
	# zero the counters before we implement new rules:
	#
	"${iptables}" -F
	"${iptables}" -X
	"${iptables}" -Z

	"${iptables}" -F -t nat
	"${iptables}" -X -t nat
	"${iptables}" -Z -t nat


	# Set up a default DROP policy for the built-in chains.
	#
	# If we modify and re-run the script mid-session then (because we have a
	# default DROP policy), what happens is that there is a small time period
	# when packets are denied until the new rules are back in place.
	#
	# There is no period, however small, when packets that we do not want are
	# allowed.
	#
	"${iptables}" -P INPUT DROP
	"${iptables}" -P FORWARD DROP
	"${iptables}" -P OUTPUT DROP

	# Not wanting too many logs:
	#$echo "0" > /proc/sys/net/ipv4/conf/all/log_martians

	# No kernel flags here, except to make sure that IP forwarding is turned on,
	# as it is a gateway:
	#
	$echo "1" > /proc/sys/net/ipv4/ip_forward


	## ============================================================
	# RULES


	# ----------------  FORWARD ---------------------

	if [ -n "${test_client_ip}" ]; then

		# L for LAN, W for WAN:

		"${iptables}" -A FORWARD -p tcp -m tcp -o ${net_if} -d ${test_client_ip} ! --sport ${ssh_port} -j LOG --log-prefix "[FW-FWD-WO] "

		"${iptables}" -A FORWARD -p tcp -m tcp -o ${lan_if} -d ${test_client_ip} ! --sport ${ssh_port} -j LOG --log-prefix "[FW-FWD-LO] "


		"${iptables}" -A FORWARD -p tcp -m tcp -i ${net_if} -s ${test_client_ip} ! --dport ${ssh_port} -j LOG --log-prefix "[FW-FWD-WI] "

		"${iptables}" -A FORWARD -p tcp -m tcp -i ${lan_if} -s ${test_client_ip} ! --dport ${ssh_port} -j LOG --log-prefix "[FW-FWD-LI] "

	fi

	## We are masquerading the full LAN:
	"${iptables}" -t nat -A POSTROUTING -o ${net_if} -s 10.0.0.0/8 -j MASQUERADE

	# NAT reduces the MTU, so counter-measure:
	"${iptables}" -A FORWARD -p tcp --tcp-flags SYN,RST SYN -j TCPMSS -o ${net_if} --clamp-mss-to-pmtu

	# Only forward that stuff from one interface to the other, and do that with
	# connection tracking:

	# Everything from the LAN interface to the Internet one is forwarded:
	"${iptables}" -A FORWARD -i ${lan_if} -o ${net_if} -m state --state NEW,ESTABLISHED,RELATED -j ACCEPT

	# Packets from the Internet interface to the LAN one must not be new unknown
	# connections:
	#
	"${iptables}" -A FORWARD -i ${net_if} -o ${lan_if} -m state --state ESTABLISHED,RELATED -j ACCEPT



	# ----------------  OUTPUT ---------------------


	if [ -n "${test_client_ip}" ]; then

		# L for LAN, W for WAN:

		# To log all non-SSH, client-related output packets:
		"${iptables}" -A OUTPUT -p tcp -m tcp -o ${net_if} -d ${test_client_ip} ! --sport ${ssh_port} -j LOG --log-prefix "[FW-OUT-W] "

		# Including (larger) SSH traffic:
		#"${iptables}" -A OUTPUT -p tcp -m tcp -o ${net_if} -d ${test_client_ip} -j LOG --log-prefix "[FW-OUT-W] "


		"${iptables}" -A OUTPUT -p tcp -m tcp -o ${lan_if} -d ${test_client_ip} ! --sport ${ssh_port} -j LOG --log-prefix "[FW-OUT-L] "

		#"${iptables}" -A OUTPUT -p tcp -m tcp -o ${lan_if} -d ${test_client_ip} -j LOG --log-prefix "[FW-OUT-L] "

	fi

	# Second rule is to let packets through which belong to established or
	# related connections and we let all traffic out, as we trust ourself:
	#
	"${iptables}" -A OUTPUT -m state --state NEW,ESTABLISHED,RELATED -j ACCEPT




	# ----------------  INPUT ---------------------

	if [ -n "${test_client_ip}" ]; then

		# To log all non-SSH, client-related input packets:

		"${iptables}" -A INPUT -p tcp -m tcp -i ${net_if} -s ${test_client_ip} ! --dport ${ssh_port} -j LOG --log-prefix "[FW-IN-W] "

		#"${iptables}" -A INPUT -p tcp -m tcp -i ${net_if} -s ${test_client_ip} --dport ${ssh_port} -j ACCEPT

		#"${iptables}" -A INPUT -p tcp -m tcp -i ${net_if} -s ${test_client_ip} -j LOG --log-prefix "[FW-IN-W] "
	#"${iptables}" -A INPUT -p tcp -m tcp -i ${net_if} -s ${test_client_ip} -j ACCEPT

		"${iptables}" -A INPUT -p tcp -m tcp -i ${lan_if} -s ${test_client_ip} ! --dport ${ssh_port} -j LOG --log-prefix "[FW-IN-L] "

	#"${iptables}" -A INPUT -p tcp -m tcp -i ${lan_if} -s ${test_client_ip} --dport ${ssh_port} -j ACCEPT

	#"${iptables}" -A INPUT -p tcp -m tcp -i ${lan_if} -s ${test_client_ip} -j LOG --log-prefix "[FW-IN-L] "
	#"${iptables}" -A INPUT -p tcp -m tcp -i ${lan_if} -s ${test_client_ip} -j ACCEPT

	fi

	"${iptables}" -A INPUT -m state --state INVALID -j DROP

	# Filter out broadcasts:
	"${iptables}" -A INPUT -m pkttype --pkt-type broadcast -j DROP


	# Drops directly connections coming from the Internet with unroutable
	# (private) addresses:
	#
	"${iptables}" -A INPUT -i ${net_if} -s 10.0.0.0/8     -j DROP
	"${iptables}" -A INPUT -i ${net_if} -s 127.0.0.0/8    -j DROP
	"${iptables}" -A INPUT -i ${net_if} -s 172.16.0.0/12  -j DROP


	# Accept non-new inputs:
	"${iptables}" -A INPUT -m state --state ESTABLISHED,RELATED -j ACCEPT


	 ## HTTP (for webserver):
	"${iptables}" -A INPUT -p tcp --dport 80 -m state --state NEW -j ACCEPT

	# HTTPS (for webserver as well):
	#"${iptables}" -A INPUT -p tcp --dport 443 -m state --state NEW -j ACCEPT


	## SSH:

	# Unlimited input from LAN:
	"${iptables}" -A INPUT -i ${lan_if} -p tcp --dport ${ssh_port} -m state --state NEW -j ACCEPT


	# Allow UDP & TCP packets to the DNS server from LAN clients (only needed if
	# this gateway is a LAN DNS server, for example with dnsmasq).
	#
	"${iptables}" -A INPUT -i ${lan_if} -p tcp --dport 53 -m state --state NEW -j ACCEPT
	"${iptables}" -A INPUT -i ${lan_if} -p udp --dport 53 -m state --state NEW -j ACCEPT



	## LOOPBACK
	# Allow unlimited traffic on the loopback interface, e.g. needed for KDE,
	# Gnome, etc.:
	"${iptables}" -A INPUT  -i lo -j ACCEPT
	"${iptables}" -A OUTPUT -o lo -j ACCEPT


	# ---------------- ICMP ---------------------

	# Everybody from the LAN can ping me (but no one from the Internet - however
	# the network box may answer instead):

	# Comment that line if no one should be able to ping you:
	"${iptables}" -A INPUT -i ${lan_if} -p icmp --icmp-type ping -j ACCEPT


	# ---------------- NTP ---------------------

	# Local clients can ask for gateway-synchronized time:
	"${iptables}" -A INPUT -i ${lan_if} -p udp --dport 123 -m state --state NEW,ESTABLISHED,RELATED -j ACCEPT


	# ---------------- LOGGING -------------------

	# Log everything else, up to 2 pings per min:
	#
	# (should be disabled if connected to the Internet, as far too verbose in
	# system logs, might hide other important events)
	#
	#"${iptables}" -A INPUT -m limit --limit 2/minute -j LOG


	$echo "Set rules are:" >> "${log_file}"
	"${iptables}" -nvL --line-numbers >> "${log_file}"
	$echo "# ---- End of minimal gateway rules, on $(date)." >> "${log_file}"

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

	$echo "Disabling Minimal gateway firewall rules (DANGER!)."

	# Load appropriate modules:
	${modprobe} ip_tables 2>/dev/null

	# We remove all rules and pre-exisiting user defined chains and zero the
	# counters before we implement new rules:
	"${iptables}" -F
	"${iptables}" -X
	"${iptables}" -Z

	"${iptables}" -F -t nat
	"${iptables}" -X -t nat
	"${iptables}" -Z -t nat

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
	$echo "(reloading)"
	shut_it_down
	start_it_up
	;;

  restart)
	$echo "(restarting)"
	# Note: at least in general, using the 'restart' option will not break a
	# remote SSH connection issuing that command.
	#
	shut_it_down
	start_it_up
	;;

  status)
	$echo "(status)"
	"${iptables}" -L
	;;

  disable)
	$echo "Disabling all rules (hence disabling the firewall)"
	"${iptables}" -F INPUT
	"${iptables}" -P INPUT ACCEPT

	"${iptables}" -F FORWARD
	"${iptables}" -P FORWARD ACCEPT

	"${iptables}" -F OUTPUT
	"${iptables}" -P OUTPUT ACCEPT
	;;

  *)
	$echo " Error, no appropriate action specified." >&2

	if [ -z "${NAME}" ]; then

		# Launched from the command-line:
		$echo "${usage}" >&2

	else

		$echo "Usage: /etc/init.d/$NAME ${script_opts}" >&2

	fi

	exit 2

  ;;

esac

$echo
$echo "The content of log file ('${log_file}') follows:"
/bin/cat "${log_file}"

exit 0
