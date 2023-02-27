#!/bin/sh

usage="Usage: $(basename $0) [NTP_SERVER]: sets time and date by NTP thanks to specified or default server."

ntp_server="$1"

if [ -z "${ntp_server}" ]; then

	# In most cases it is best to use:
	ntp_server="pool.ntp.org"

	#ntp_server="server 0.fr.pool.ntp.org"
	#ntp_server="server 1.fr.pool.ntp.org"
	#ntp_server="server 2.fr.pool.ntp.org"
	#ntp_server="server 3.fr.pool.ntp.org"

	#ntp_server="ntp.imag.fr"

fi

if [ $(id -u) = "0" ]; then

	echo "Setting time and date by NTP thanks to ${ntp_server}..."
	if ntpdate -u ${ntp_server}; then

		echo "Success!"

	else

		echo "Synchronisation failed." 1>&2

		exit 5

	fi

else

	echo "Error, you must be root to do that." 1>&2

	exit 15

fi
