#!/bin/sh

usage="Usage: $(basename $0) [-h|--help] [enable|disable|display]: enables, disables or displays (the default action) the current status of the Internet connectivity of any registered CCTV camera.
Disabling it means adding a firewall rule filtering out all outgoing packets sent by the IP address of the CCTV (itself probably determined from its MAC address), thereby avoiding any leak of information to third parties. Conversely, its streams will not be available anymore from one's smartphone, software updates will not be done, etc.
This script must be run with root permissions.
"


if [ "$1" = "-h" ] || [ "$1" = "--help" ]; then

	echo "${usage}"

	exit

fi


# Default:
action="display"

if [ $# -ge 2 ]; then

	echo "  Error, up to one argument expected.
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

	else

		echo "  Error, unexpected argument ('$1').
${usage}" 1>&2

		exit 10

	fi

fi


settings_file="${HOME}/.ceylan-settings.etf"

# Possibly a symlink:
if [ ! -e "${settings_file}" ]; then

	echo "  Error, no settings file (${settings_file}) found." 1>&2

	exit 15

fi


#echo "Reading the '${settings_file}' configuration file."

cam_host_key="camera_1_hostname"

cctv_host="$(/bin/cat "${settings_file}" | grep -v '^[[:space:]]*%' | grep "${cam_host_key}" | sed 's|.*,[[:space:]]*"||1' | sed 's|[[:space:]]*"[[:space:]]*}.$||1')"

#echo "Read CCTV configured from '${settings_file}': ${cctv_host}."

if [ -z "${cctv_host}" ]; then

	echo "  Error, no CCTV host registered in '${settings_file}' (no '${cam_host_key}' entry)." 1>&2

	exit 20

fi


#echo "Selected action: ${action} the Internet connectivity of CCTV host '${cctv_host}'."

iptables="$(which iptables 2>/dev/null)"

if [ ! -x "${iptables}" ]; then

	echo "  Error, no 'iptables' executable available." 1>&2

	exit 20

fi


if [ "${action}" = "display" ]; then

	echo "  Displaying the current firewall rules mentioning the CCTV host '${cctv_host}' (as determined from '${settings_file}'):"

elif [ "${action}" = "enable" ]; then

	echo "  Enabling the Internet connectivity of the CCTV host '${cctv_host}' (as determined from '${settings_file}')."

	# May not be defined:
	${iptables} -D FORWARD -s "${cctv_host}" -j DROP 2>/dev/null

	echo "Result: "

elif [ "${action}" = "disable" ]; then

	echo "  Disabling the Internet connectivity of the CCTV host '${cctv_host}' (as determined from '${settings_file}')."

	#A bit more precise: iptables -I FORWARD -s 10.0.18.103/32 -i my_lan_interface -j DROP

	${iptables} -I FORWARD -s "${cctv_host}" -j DROP

	echo "Result: "

else

	echo "(unsupported action '${action}')"

	exit 50

fi

${iptables} --list | grep "^Chain \|${cctv_host}"
