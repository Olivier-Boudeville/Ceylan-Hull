#!/bin/sh

NTP_SERVER=ntp.imag.fr

echo "Setting time and date by NTP thanks to $NTP_SERVER"

if [ `id -u` = "0" ]; then
	ntpdate -u $NTP_SERVER
else
	echo "You must be root to do that."
fi
