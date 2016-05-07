#!/bin/sh


USAGE="Usage: "$(basename $0)" [ status | start | scan | stop | isolate | --help ]:
  - without argument or with 'status': returns status
  - with 'start': put the wireless interface up
  - with 'scan': scan for wireless access points (once started)
  - with 'stop': put the wireless interface down"


if [ "$1" = "--help" ] ; then

	echo "$USAGE"
	exit 0x

fi


if [ ! $(id -u) -eq 0 ]; then

	echo "  Error, you must be root." 1>&2
	exit 5

fi


IW=$(which iw 2>/dev/null)


if [ ! -x "$IW" ] ; then

	echo "  Error, no available 'iw' tool (use 'pacman -S iw'?)." 1>&2
	exit 10

fi


IP=$(which ip 2>/dev/null)

if [ ! -x "$IP" ] ; then

	echo "  Error, no available 'ip' tool (use 'pacman -S ip'?)." 1>&2
	exit 11

fi


RFKILL=$(which rfkill 2>/dev/null)


if [ ! -x "$RFKILL" ] ; then

	echo "  Error, no available 'rfkill' tool (use 'pacman -S rfkill'?)." 1>&2
	exit 12

fi


IF=$($IW dev|grep Interface | sed 's|.*Interface ||')

if [ -n "$IF" ] ; then

	echo "Guessed wireless interface: $IF"

else

	IF="wlo1"
	echo "Unable to guess wireless interface, assuming $IF."

fi


arg="$1"

if [ -z "$arg" ] ; then

	echo "Information about wireless interface $IF: "$($IW dev $IF link)

elif [ "$arg" = "status" ] ; then

	$RFKILL list
	echo "Status of wireless interface $IF: "$($IW dev $IF link)

elif [ "$arg" = "start" ] ; then

	echo "Setting wireless interface $IF up."
	$RFKILL unblock wifi
	$IP link set $IF up
	#$IW dev $IF link

elif [ "$arg" = "stop" ] ; then

	echo "Setting wireless interface $IF down."
	$IP link set $IF down
	$RFKILL block wifi

	#$IW dev $IF link

elif [ "$arg" = "scan" ] ; then

	echo "Scanning with interface $IF:"
	$IW dev $IF scan | grep SSID

elif [ "$arg" = "isolate" ] ; then

	echo "Blocking all wireless accesses now."
	$RFKILL block all

else

	echo "  Error, invalid argument ('$arg')." 1>&2
	exit 15

fi


# To connect:

# First, ensure that RFKILL is disabled:
# We must have:
# rfkill list wifi
#0: phy0: Wireless LAN
#	Soft blocked: no
#	Hard blocked: no
#
# If hard blocked, toggle an hardware button.
# If soft blocked, push once the wireless key (F12)
# Then re-check.
#


# - if no encryption: 'iw dev $IF connect $ESSID'
# - if WEP is used: 'iw dev $IF connect $ESSID key 0:$KEY'
# - if using WPA/WPA2:

# netctl start "wlo1-100_Fils_d'Ariane"

# If failed:
# ip link set wlo1 down
# netctl start "wlo1-100_Fils_d'Ariane"

# Otherwise:
# 'wpa_supplicant -i $IF -c < ( wpa_passphrase $ESSID $KEY )'

# Check with 'status'.

# Then:
#
# - either 'dhcpcd $IF'
# - or, for example:

# ip addr add 192.168.0.2/24 dev $IF
# ip route add default via 192.168.0.1

# One may also use:

# - wifi-radar
# - wifi-menu
# - rfkill
