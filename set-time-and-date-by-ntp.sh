#!/bin/sh


# In most cases it is best to use:
default_ntp_server="pool.ntp.org"

#default_ntp_server="server 0.fr.pool.ntp.org"
#default_ntp_server="server 1.fr.pool.ntp.org"
#default_ntp_server="server 2.fr.pool.ntp.org"
#default_ntp_server="server 3.fr.pool.ntp.org"

#default_ntp_server="ntp.imag.fr"

help_short_opt="-h"
help_long_opt="--help"


usage="Usage: $(basename $0) [${help_short_opt}|${help_long_opt}] [NTP_SERVER]: sets time and date by NTP thanks to the specified or default (${default_ntp_server}) server."

if [ "$1" = "${help_short_opt}" ] || [ "$1" = "${help_long_opt}" ]; then

   echo "${usage}"

   exit

fi


ntp_server="$1"

if [ -z "${ntp_server}" ]; then

	ntp_server="${default_ntp_server}"

fi

if [ $(id -u) = "0" ]; then

	ntpdate="$(which ntpdate 2>/dev/null)"

	if [ ! -x "${ntpdate}" ]; then

		echo "  Error, no ntpdate executable found. On Arch, install the 'ntp' package for that." 1>&2

		exit 50

	fi

	echo "Setting time and date by NTP thanks to ${ntp_server}..."
	if "${ntpdate}" -u "${ntp_server}"; then

		echo "  Success!"

	else

		echo "  Synchronisation failed." 1>&2

		exit 5

	fi

else

	echo "  Error, you must be root to do that." 1>&2

	exit 15

fi
