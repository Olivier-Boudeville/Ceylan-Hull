#!/bin/sh


# To prefer LAN rules to the default Gateway ones:
lan_opt="--lan-rules"


# 20 minutes:
sleep_duration=1200

usage="Usage: $(basename $0) ${script_opts} [${lan_opt}]: disables temporarily (for ${sleep_duration} seconds) all firewall rules, and restores, by default, gateway ones - unless the ${lan_opt} is specified, in which case LAN ones will be used instead."

firewall_script_name="iptables.rules-Gateway.sh"


if [ "$1" = "${lan_opt}" ]; then

	echo "(LAN rules will be restored)"
	firewall_script_name="iptables.rules-LANBox.sh"

	shift

fi


if [ -n "$1" ]; then

	echo "  Error, invalid parameter.
${usage}" 1>&2

	exit 45

fi


iptables="/sbin/iptables"

if [ ! -x "${iptables}" ]; then

	echo "  Error, iptables (${iptables}) not found." 1>&2
	exit 50

fi


if [ ! $(id -u) -eq 0 ]; then

	echo "
	Error, you must be root, aborting." 1>&2
	exit 5

fi


firewall_script="$(which ${firewall_script_name})"

if [ ! -x "${firewall_script}" ]; then

	echo "
	Error, no firewall script found to set back the firewall (${firewall_script_name}), aborting." 1>&2

	exit 10

fi


echo "Disabling temporarily ALL iptables rules (beware, all traffic accepted!), before restoring rules thanks to '${firewall_script}'..."


${iptables} -F && ${iptables} -X && ${iptables} -Z && ${iptables} -F -t nat && ${iptables} -X -t nat && ${iptables} -Z -t nat && ${iptables} -P INPUT ACCEPT && ${iptables} -P FORWARD ACCEPT && ${iptables} -P OUTPUT ACCEPT

if [ ! $? -eq 0 ]; then

	echo "
	Error, disabling failed, trying to reset directly the base (gateway) rules." 1>&2
	${firewall_script} start

	exit 15

else

	echo "(reported success)"

fi



echo "Sleeping for ${sleep_duration} seconds..."
sleep "${sleep_duration}"

echo "...awoken, restoring rules with ${firewall_script} now..."

${firewall_script} start && echo "... restored!"
