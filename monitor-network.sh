#!/bin/sh

# Reliable:
public_ip=8.8.8.8

# For testing:
#public_ip=10.0.0.1

# Every 5 minutes:
sec_count=300

# 2 minutes:
#sec_count=120

#sec_count=30

# For testing:
#sec_count=2

usage="Usage: $(basename $0) [--inter-check-duration SECS] [--notify-ok|--notify-ko]: monitors the local network connection to the Internet, by pinging the IP address of a reliable public server (${public_ip}) periodically (by default every ${sec_count} seconds), as long as not interrupted with a CTRL-C.

Options:
  --inter-check-duration SECS: sets the number of seconds between two checks
  --notify-ok: notifies (by a sound) each time the Internet connection is found functional
  --notify-ko: notifies (by a sound) each time the Internet connection is found dysfunctional
"


if [ "$1" = "-h" ] || [ "$1" = "--help" ]; then

	echo "${usage}"
	exit 0

fi


notify_ok=1
notify_ko=1

if [ "$1" = "--inter-check-duration" ]; then
	shift
	sec_count="$1"
	shift
	echo "Will perform a check every ${sec_count} seconds."
fi

if [ "$1" = "--notify-ok" ]; then
	echo "Will notify whenever the Internet connection is found functional."
	notify_ok=0
	shift
fi

if [ "$1" = "--notify-ko" ]; then
	echo "Will notify whenever the Internet connection is found dysfunctional."
	notify_ko=0
	shift
fi


if [ ! $# -eq 0 ]; then

	echo "  Error, unexpected parameters: '$*'.
${usage}" 1>&2

	exit 5

fi

echo "  Pinging ${public_ip} every ${sec_count} seconds..."

while true; do

	if ping -q -c 1 ${public_ip} 1>/dev/null 2>&1; then

		echo " - at $(date): OK !!!!!"
		if [ ${notify_ok} -eq 0 ]; then
			bong.sh 1>/dev/null
		fi

	else

		echo " - at $(date): KO :-(" 1>&2
		if [ ${notify_ko} -eq 0 ]; then
			bong.sh 1>/dev/null
		fi

	fi

	sleep ${sec_count}

done
