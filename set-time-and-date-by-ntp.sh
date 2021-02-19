#!/bin/sh

usage="Usage: $(basename $0) [NTP_SERVER]: sets time and date by NTP thanks to specified or default server."

ntp_server="$1"

if [ -z "${ntp_server}" ]; then
	ntp_server="ntp.imag.fr"
fi


if [ $(id -u) = "0" ]; then

	echo "Setting time and date by NTP thanks to ${ntp_server}..."
	ntpdate -u ${ntp_server}

else

	echo "Error, you must be root to do that." 1>&2

	exit 5

fi
