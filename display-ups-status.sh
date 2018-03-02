#!/bin/sh

# An UPS may be queried through NUT (with upsc) or thanks to a vendor-specific
# client like the APC UPS daemon (with apcaccess).

UPSC=$(which upsc 2>/dev/null)

if [ -x "${UPSC}" ] ; then

	UPS_NAME="myBelkin"
	UPS_SERVER="aranor"

	echo "Displaying state of UPS ${UPS_NAME}@${UPS_SERVER}:"
	$UPSC ${UPS_NAME}@${UPS_SERVER}

else

	# Typically obtained through: pacman -Sy apcupsd; then
	# /etc/apcupsd/apcupsd.conf shall be updated accordingly.

	# Otherwise: "Error contacting apcupsd @ localhost:3551: Connection refused"

	APCC=$(which apcaccess 2>/dev/null)

	if [ -x "${APCC}" ] ; then

		echo "Displaying state of APC UPS:"
		$APCC status

	else


		echo "  Error, no UPS client found (neither upsc nor apcaccess in the path)." 1>&2

		exit 5

	fi

fi
