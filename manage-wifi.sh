#!/bin/sh

usage="Usage: $(basename $0) [--help|-h] [status|start|scan|stop|isolate]: manages the local Wifi configuration
  - without argument or with 'status': returns status
  - with 'start': put the (guessed) wifi interface up
  - with 'scan': scan for wifi access points (once started)
  - with 'stop': put the (guessed) wifi interface down (and blocks it)
  - with 'isolate': ensures that no Wifi communication happens"


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

	# Could be various names like:
	#if="wlo1"
	if="wlp4s0"
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

	# See also: 'iwlist interface scan'.

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
#0: YOUR_CARD: Wireless LAN
#	Soft blocked: no
#	Hard blocked: no
#
# If hard blocked, toggle an hardware button (e.g. Ctrl-F8 on a Thinkpad whose
# Fn/Ctrl keys have been swapped in the BIOS).
#
# If soft blocked, push once the wireless key (e.g. F8 or F12, or 'rfkill
# unblock 1', or use this script with its 'start' argument).
#
# Then re-check.


# Simplest configuration: run 'wifi-menu' as root, to generate a proper netctl
# configuration.
#
# Otherwise one may take inspiration from the profiles in /etc/netctl/examples
#
# - if no encryption: 'iw dev ${if} connect $ESSID'
# - if WEP is used: 'iw dev ${if} connect $ESSID key 0:$KEY'
# - if using WPA/WPA2:

# Let's then suppose that your profile is defined in
# "/etc/netctl/wlo1-100_Fils_d'Ariane":

# netctl start "wlo1-100_Fils_d'Ariane"

# If failed:
# ip link set ${if} down
# netctl start "wlo1-100_Fils_d'Ariane"

# Otherwise, still as root (add -B to run as a daemon):
# 'wpa_supplicant -i ${if} -c < (wpa_passphrase "${ESSID}" "${KEY}")'

# Check with 'status'.
# Maybe add it for good with 'enable'.

# Another option is to use directly iw (see
# https://wiki.archlinux.org/title/Network_configuration/Wireless), as root.
#
# Use 'iw dev' to list wireless interfaces.
#
# After the command prefix 'iw dev ${if}':
# - to get link status: link
# - to get link statistics: station dump
# - to scan for available access points: scan
# - to set the operation mode to ad-hoc (peer to peer, no central controller):
# set type ibss
# - to connect to:
#     * an open network: connect $ESSID
#     * a WEP-encrypted network using an hexadecimal or ASCII key:
#         connect $ESSID key 0:$KEY
#     * for a WPA* network: use wpa_supplicant above

# Then, in all cases, once connected:
# - either with a DHCP client: 'dhcpcd ${if}'
# - or, for example:
# ip addr add 192.168.0.2/24 dev ${if}
# ip route add default via 192.168.0.1

# One may also use:
# - to check that the kernel loaded the driver for the wireless card: lspci -k
# - netctl
# - iwconfig (from extra/wireless_tools)
# - rfkill
# - iwd
#
# Otherwise USB tethering could be considered.
#
# or, as a last resort, sacrifice three chickens to the Wifi gods.
