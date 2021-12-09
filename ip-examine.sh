#!/bin/sh

usage="Usage: $(basename $0) [-h|--help] IP
Returns locally-determined information regarding the specified IP.

Ex: '$(basename $0) 10.0.7.14'.
"


if [ "$1" = "-h" ] || [ "$1" = "-h" ]; then

	echo "${usage}"

	exit 0

fi


if [ ! $# -eq 1 ]; then

	echo "
${usage}" 1>&2

	exit 5

fi

target_ip="$1"

echo " Examining IP ${target_ip}..."

if ping -c 1 "${target_ip}" 1>/dev/null; then

	echo " - answers to ping"

else

	echo " - does not answer to our ping"

fi

# drill is from ldns package:
drill="$(which drill 2>/dev/null)"

if [ -x "${drill}" ]; then

	dns_name=$( "${drill}" -x "${target_ip}" | grep '^;; ANSWER SECTION:' --after-context=1 | grep -v '^;; ANSWER SECTION:' | sed 's|.*PTR[[:space:]]||1' | sed 's|\.$||1')

	if [ -n "${dns_name}" ]; then

		echo " - DNS name found from reverse look-up: '${dns_name}'"

	else

		echo " - no DNS name found from reverse look-up"

	fi

else

	echo "(no 'drill' executable found, no reverse lookup performed)"

	# dig and nslookup could be tried then.

fi


traceroute="$(which traceroute 2>/dev/null)"

if [ -x "${traceroute}" ]; then

	echo " - determining a route to this IP:"

	# ICMP (-I) does not require root permissions, whereas TCP (-T) does:
	"${traceroute}" -I "${target_ip}"

else

	echo "(no 'traceroute' executable found, no route determined)"

fi


arp="$(which arp 2>/dev/null)"

if [ -x "${arp}" ]; then

	echo " - determining whether IP in local ARP cache:"

	"${arp}" "${target_ip}"

else

	echo "(no 'arp' executable found, no local ARP cache searched)"

fi
