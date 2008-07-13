#/bin/sh

echo "Disabling temporary ALL iptables rules (beware!)"

iptables -X
iptables -t nat -F
iptables -t nat -X
iptables -t mangle -F
iptables -t mangle -X
iptables -P INPUT ACCEPT
iptables -P FORWARD ACCEPT
iptables -P OUTPUT ACCEPT

SLEEP_DURATION=1000
echo "Sleeping for $SLEEP_DURATION seconds..."
sleep 1000

FIREWALL_SCRIPT="/etc/init.d/iptables.rules-Gateway.sh"

echo "...awoken, reseting rules from $FIREWALL_SCRIPT..."

${FIREWALL_SCRIPT} && echo "... done!"

