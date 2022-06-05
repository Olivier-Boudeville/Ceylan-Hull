#!/bin/sh

usage="Usage: $(basename $0) [--help|-h] [status|start|scan|stop|isolate]: manages the wifi configuration
  - without argument or with 'status': returns status
  - with 'start': put the (guessed) wifi interface up
  - with 'scan': scan for wifi access points (once started)
  - with 'stop': put the (guessed) wifi interface down"


if [ "$1" = "--help" ] || [ "$1" = "-h" ]; then

	echo "${usage}"
	exit 0

fi


if [ ! $(id -u) -eq 0 ]; then

	echo "  Error, you must be root." 1>&2
	exit 5

fi


iw="$(which iw 2>/dev/null)"


if [ ! -x "${iw}" ]; then

	echo "  Error, no available 'iw' tool (use 'pacman -S iw'?)." 1>&2
	exit 10

fi


ip="$(which ip 2>/dev/null)"

if [ ! -x "${ip}" ]; then

	echo "  Error, no available 'ip' tool (use 'pacman -S ip'?)." 1>&2
	exit 11

fi


rfkill="$(which rfkill 2>/dev/null)"


if [ ! -x "${rfkill}" ]; then

	echo "  Error, no available 'rfkill' tool (use 'pacman -S rfkill'?)." 1>&2
	exit 12

fi


if="$(${iw} dev | grep Interface | sed 's|.*Interface ||')"

if [ -n "${if}" ]; then

	echo "Guessed wifi interface: ${if}"

else

	if="wlo1"
	echo "Unable to guess wifi interface, assuming ${if}."

fi


arg="$1"

if [ -z "${arg}" ] || [ "${arg}" = "status" ]; then

	${rfkill} list
	echo "Status of wifi interface ${if}: $(${iw} dev ${if} link)"

elif [ "${arg}" = "start" ]; then

	${rfkill} unblock wifi

	# Disabled as it resulted in netctl failing, expecting the interface to be
	# down:
	#echo "Setting wifi interface ${if} up."
	#${ip} link set ${if} up

	#${iw} dev ${if} link

elif [ "${arg}" = "stop" ]; then

	echo "Setting wifi interface ${if} down."
	${ip} link set "${if}" down
	${rfkill} block wifi

	#${iw} dev ${if} link

elif [ "${arg}" = "scan" ]; then


	# If the wifi interface is reported as blocked, one may use for example:
	# 'rfkill unblock 1'.

	# Otherwise an error "command failed: Network is down (-100)" is triggered:
	echo "Setting wifi interface ${if} up."
	${ip} link set "${if}" up

	echo "Scanning for wifi networks with interface ${if}, found following SSIDs:"
	${iw} dev "${if}" scan | grep 'SSID: ' | sort | uniq | sed 's|.*SSID: | - |1'

	# Expected by netctl:
	echo "Setting wifi interface ${if} down."
	${ip} link set "${if}" down

elif [ "${arg}" = "isolate" ]; then

	echo "Blocking all wireless accesses now."
	${rfkill} block all

else

	echo "  Error, invalid argument ('${arg}')." 1>&2
	exit 15

fi


# To connect:

# First, ensure that rfkill is disabled:
# We must have:
# rfkill list wifi
#0: phy0: Wireless LAN
#	Soft blocked: no
#	Hard blocked: no
#
# If hard blocked, toggle an hardware button.
#
# If soft blocked, push once the wireless key (ex: F8 or F12, or 'rfkill unblock
# 1')
#
# Then re-check.


# - if no encryption: 'iw dev ${if} connect $ESSID'
# - if WEP is used: 'iw dev ${if} connect $ESSID key 0:$KEY'
# - if using WPA/WPA2:

# netctl start "wlo1-100_Fils_d'Ariane"

# If failed:
# ip link set wlo1 down
# netctl start "wlo1-100_Fils_d'Ariane"

# Otherwise:
# 'wpa_supplicant -i ${if} -c < ( wpa_passphrase $ESSID $KEY )'

# Check with 'status'.

# Then:
# - either 'dhcpcd ${if}'
# - or, for example:
# ip addr add 192.168.0.2/24 dev ${if}
# ip route add default via 192.168.0.1

# One may also use:
# - wifi-radar
# - wifi-menu
# - rfkill
