#!/bin/sh

# Default:
camera_id=1

usage="Usage: $(basename $0) [-h|--help] [enable|disable|display] [CAMERA_ID]: enables, disables or displays (the default action) the current status of the Internet connectivity of the networked security camera (CCTV) designated by any CAMERA_ID specified, otherwise by the default camera identifier,'${camera_id}'.
Disabling it means adding a firewall rule filtering out all outgoing packets sent by the IP address of the corresponding CCTVs (themselves probably determined from their MAC address), thereby avoiding any leak of information to third parties. Conversely, their streams will not be available anymore from one's smartphone, software updates will not be done, they cannot be configured anymore, etc.
This script must be run with root permissions.
"


if [ "$1" = "-h" ] || [ "$1" = "--help" ]; then

	echo "${usage}"

	exit

fi


if [ ! $(id -u) -eq 0 ]; then

	echo "  Error, you must be root.
${usage}" 1>&2

	exit 4

fi


# Default:
action="display"

if [ $# -ge 3 ]; then

	echo "  Error, up to two arguments expected.
${usage}" 1>&2

	exit 5

fi


if [ -n "$1" ]; then

	if [ "$1" = "enable" ]; then

		action="enable"

	elif [ "$1" = "disable" ]; then

		action="disable"

	elif [ "$1" = "display" ]; then

		# Even if default:
		action="display"

	fi

	shift

fi


if [ -n "$1" ]; then

	camera_id="$1"
	shift

fi

echo "Will set the network connectivity of the camera of identifier '${camera_id}'."

iptables="$(which iptables 2>/dev/null)"

if [ ! -x "${iptables}" ]; then

	echo "  Error, no 'iptables' executable available." 1>&2

	exit 20

fi


settings_file="${HOME}/.ceylan-settings.etf"

# Possibly a symlink:
if [ ! -e "${settings_file}" ]; then

	echo "  Error, no settings file (${settings_file}) found." 1>&2

	exit 15

fi


#echo "Reading the '${settings_file}' configuration file."

cam_host_key="camera_${camera_id}_hostname"

cctv_host="$(grep -v '^[[:space:]]*%' "${settings_file}" | grep "${cam_host_key}" | sed 's|.*,[[:space:]]*"||1' | sed 's|[[:space:]]*"[[:space:]]*}.$||1')"

if [ -z "${cctv_host}" ]; then

	echo "  Error, no CCTV host registered in '${settings_file}' (no '${cam_host_key}' entry)." 1>&2

	exit 25

fi

#echo "Read CCTV configured from '${settings_file}': ${cctv_host}."

# We thought wrongly that iptables to delete a rule wanted its literal
# specification, with hostnames already translated into IPs (actually another
# element - namely the input interface - was in the way).


# We will need its IP address, if it is not one already:
# if expr "${cctv_host}" : '[0-9][0-9]*\.[0-9][0-9]*\.[0-9][0-9]*\.[0-9][0-9]*$' >/dev/null; then

#	cctv_host_ip="${cctv_host}"
#	echo "(CCTV host was already specified an IP: ${cctv_host_ip})"

# else

#	# More relevant than 'getent hosts':
#	cctv_host_ip="$(host ${cctv_host} | head -n1 | sed 's|.*has address ||1' 2>/dev/null)"

#	if [ -z "${cctv_host_ip}" ]; then

#		echo "  Error, failed to resolve an IP for CCTV host '${cctv_host}'." 1>&2

#		exit 55

#	fi

#	#echo "(resolved CCTV host '${cctv_host}' into IP '${cctv_host_ip}')"

# fi



#echo "Selected action: ${action} the Internet connectivity of CCTV host '${cctv_host}'."

##echo "Selected action: ${action} the Internet connectivity of CCTV host '${cctv_host}' (IP: ${cctv_host_ip})."


# We prefer in our general firewall configuration (see
# iptables.rules-Gateway.sh) to filter untrusted local (LAN) (see hosts
# filtered_local_hosts) by specifying also their (LAN) interface.
#
# However, for this current script to delete such rules, it must know that
# interface (otherwise the rule specifications will not match):
#
# So:

fw_settings_file="/etc/iptables.settings-Gateway.sh"

if [ -e "${fw_settings_file}" ]; then

	lan_if_name="$(grep '^lan_if=' ${fw_settings_file} | sed 's|lan_if=||1; s|\"||g')"

	if [ -z "${lan_if_name}" ]; then

		echo "  Error, unable to determine LAN interface name from the '${fw_settings_file}' firewall settings file." 1>&2

		exit 60

	fi

	#echo "(using LAN interface name '${lan_if_name}', as determined from the '${fw_settings_file}' firewall settings file)"

	lan_if_spec="-i ${lan_if_name}"

else

	echo "  Warning: no '{fw_settings_file}' firewall settings file, not specifying rules with LAN interface names." 1>&2

	lan_if_spec=""

fi



# We insert/delete the FORWARD drop rule for the CCTV based on its
# specification, which can be obtained thanks to 'iptables -S'.


if [ "${action}" = "display" ]; then

	echo "  Displaying the current firewall rules mentioning the CCTV host '${cctv_host}', as determined from '${settings_file}':"

	#echo "  Displaying the current firewall rules mentioning the CCTV host '${cctv_host}' (of IP: ${cctv_host_ip}), as determined from '${settings_file}':"


elif [ "${action}" = "enable" ]; then

	echo "  Enabling the Internet connectivity of the CCTV host '${cctv_host}', as determined from '${settings_file}'."

	#echo "  Enabling the Internet connectivity of the CCTV host '${cctv_host}' (of IP: ${cctv_host_ip}), as determined from '${settings_file}'."

	# May not be defined, or be defined more than once:
	while "${iptables}" -D FORWARD ${lan_if_spec} -s "${cctv_host}" -j DROP 2>/dev/null; do
		echo "(removed forwarding drop rule)"
	done

	echo "Result: "


elif [ "${action}" = "disable" ]; then

	echo "  Disabling the Internet connectivity of the CCTV host '${cctv_host}', as determined from '${settings_file}'."

	#echo "  Disabling the Internet connectivity of the CCTV host '${cctv_host}' (of IP: ${cctv_host_ip}), as determined from '${settings_file}'."

	# Should there be multiple instances of this rule set, they will be removed
	# at the next 'enable' run, yet we prefer avoiding edge cases:
	#
	#if "${iptables}" --list FORWARD | grep "^DROP.*${cctv_host}.*\|^DROP.*${cctv_host_ip}.*"; then
	if "${iptables}" --list FORWARD | grep "^DROP.*${cctv_host}.*"; then

		echo "(forwarding drop rule apparently already set)"

	else

		#"${iptables}" -I FORWARD ${lan_if_spec} -s "${cctv_host_ip}" -j DROP
		"${iptables}" -I FORWARD ${lan_if_spec} -s "${cctv_host}" -j DROP

		echo "(forwarding drop rule set)"

	fi

	echo "Result: "

else

	echo "(unsupported action '${action}')"

	exit 50

fi

"${iptables}" --list | grep "^Chain \|${cctv_host}"
#"${iptables}" --list | grep "^Chain \|${cctv_host_ip}\|${cctv_host}"
