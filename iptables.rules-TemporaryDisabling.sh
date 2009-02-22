#/bin/sh

echo "Disabling temporarily ALL iptables rules (beware, all traffic accepted!)"

iptables -X
iptables -t nat -F
iptables -t nat -X
iptables -t mangle -F
iptables -t mangle -X
iptables -P INPUT ACCEPT
iptables -P FORWARD ACCEPT
iptables -P OUTPUT ACCEPT

sleep_duration=1000
echo "Sleeping for $sleep_duration seconds..."
sleep $sleep_duration

firewall_script="/etc/init.d/iptables.rules-Gateway.sh"

echo "...awoken, reseting rules with $firewall_script..."

${firewall_script} && echo "... done!"

