#!/bin/sh

usage="Usage: $(basename $0) [UPS_NAME] [UPS_SERVER]: displays the status of specified UPS."

# An UPS may be queried through NUT (with upsc) or thanks to a vendor-specific
# client like the APC UPS daemon (with apcaccess).
#
# See also: 'upower -e' and 'upower -i XXX' like in:
# for d in $(upower -e); do echo "For $d: "; upower -i $d; done
# (duplicates may be returned)

upsc="$(which upsc 2>/dev/null)"

if [ -x "${upsc}" ]; then

	ups_name="$1"

	if [ -z "${ups_name}" ]; then
		ups_name="myBelkin"
	fi

	ups_server="$2"

	if [ -z "${ups_server}" ]; then
		ups_server="aranor"
	fi

	echo "Displaying state of UPS ${ups_name}@${ups_server}:"
	${upsc} "${ups_name}@${ups_server}"

else

	# Typically obtained through: pacman -Sy apcupsd; then
	# /etc/apcupsd/apcupsd.conf shall be updated accordingly.

	# Otherwise: "Error contacting apcupsd @ localhost:3551: Connection refused"

	apcc="$(which apcaccess 2>/dev/null)"

	if [ -x "${apcc}" ]; then

		echo "Displaying state of APC UPS:"
		${apcc} status

	else

		echo "  Error, no UPS client found (neither upsc nor apcaccess in the path)." 1>&2

		exit 5

	fi

fi
