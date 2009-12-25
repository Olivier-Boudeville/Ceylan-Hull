#/bin/sh


firewall_script_name="iptables.rules-Gateway.sh"
firewall_script=`which ${firewall_script_name}`

if [ ! `id -u` -eq 0 ] ; then

	echo "  
	Error, you must be root, aborting." 1>&2
	
	exit 1
	
fi


if [ ! -x "${firewall_script}" ] ; then

	echo "  
	Error, no firewall script found to set back the firewall (${firewall_script_name}), aborting." 1>&2
	
	exit 5
	
fi

echo "Disabling temporarily ALL iptables rules (beware, all traffic accepted!)"

iptables -X && iptables -t nat -F && iptables -t nat -X && iptables -t mangle -F && iptables -t mangle -X && iptables -P INPUT ACCEPT && iptables -P FORWARD ACCEPT && iptables -P OUTPUT ACCEPT

if [ ! $? -eq 0 ] ; then

	echo "  
	Error, disabling failed, trying to reset directly the rules." 1>&2
	${firewall_script}
	
	exit 15

fi

sleep_duration=1000
echo "Sleeping for $sleep_duration seconds..."
sleep $sleep_duration

echo "...awoken, reseting rules with $firewall_script..."

${firewall_script} && echo "... done!"

