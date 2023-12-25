#!/bin/sh

usage="Usage: $(basename $0): lists the currently-used firewall rules."

if [ ! $(id -u) -eq 0 ]; then

	echo "  Error, firewall rules can only be applied by root." 1>&2

	exit 10

fi

# Default table: filter; also: nat
# Chains: INPUT, OUTPUT, FORWARD
# A list of rules per chain.


iptables=/sbin/iptables

# Line numbers are useful to designate a rule afterwards (e.g. to delete it).
# -L: list all rules of selected chain or all chains
# -v: verbose
# -n: numeric only, no (slower) resolution
#
opts="--line-numbers -L -v -n"

(

	echo
	echo " - listing all 'filter' rules:"
	echo

	# -L: list all rules of selected chain or all chains
	# -v: verbose
	# -n: numeric only, no (slower) resolution
	#
	"${iptables}" ${opts}

	echo
	echo " - printing all 'filter' rules:"
	echo
	"${iptables}" --list-rules


	echo
	echo " - listing all 'nat' rules:"
	echo
	"${iptables}" -t nat ${opts}

	echo
	echo " - printing all 'nat' rules:"
	echo
	"${iptables}" -t nat --list-rules ) | more
