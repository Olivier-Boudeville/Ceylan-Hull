#!/bin/sh

# 20 minutes:
sleep_duration=1200

usage="Usage: $(basename $0) ${script_opts}: disables temporarily (for ${sleep_duration} seconds) all firewall rules."

firewall_script_name="iptables.rules-Gateway.sh"
firewall_script=$(which ${firewall_script_name})

if [ ! $(id -u) -eq 0 ]; then

	echo "
	Error, you must be root, aborting." 1>&2
	exit 5

fi


if [ ! -x "${firewall_script}" ]; then

	echo "
	Error, no firewall script found to set back the firewall (${firewall_script_name}), aborting." 1>&2

	exit 10

fi


echo "Disabling temporarily ALL iptables rules (beware, all traffic accepted!)"


iptables=/sbin/iptables

${iptables} -F && ${iptables} -X && ${iptables} -Z && ${iptables} -F -t nat && ${iptables} -X -t nat && ${iptables} -Z -t nat && ${iptables} -P INPUT ACCEPT && ${iptables} -P FORWARD ACCEPT && ${iptables} -P OUTPUT ACCEPT


if [ ! $? -eq 0 ]; then

	echo "
	Error, disabling failed, trying to reset directly the base (gateway) rules." 1>&2
	${firewall_script}

	exit 15

else

	echo "(reported success)"

fi



echo "Sleeping for $sleep_duration seconds..."
sleep $sleep_duration

echo "...awoken, restoring rules with $firewall_script..."

${firewall_script} && echo "... restored!"
