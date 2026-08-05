#!/bin/sh

# Copyright (C) 2026-2026 Olivier Boudeville
#
# Author: Olivier Boudeville [olivier (dot) boudeville (at) esperide (dot) com]
#
# This file is part of the Ceylan-Hull toolbox (see http://hull.esperide.org).


help_short_opt="-h"
help_long_opt="--help"

usage="Usage: $(basename $0) [${help_short_opt}|${help_long_opt}] [YYYY-MM-DD] HH:MM[:SS]: sets explicitly the localhost time, and possibly date, based on the specified timestamp.

Examples of use:
 $(basename $0) 14:03:11
 $(basename $0) 2026-08-05 23:30

Must be run as root.

For a (better) NTP-based setting of time and date, refer to our set-time-and-date-by-ntp.sh script."

if [ "$1" = "${help_short_opt}" ] || [ "$1" = "${help_long_opt}" ]; then

   echo "${usage}"

   exit

fi


if [ ! "$(id -u)" = "0" ]; then

	echo " Error, this script must be as root." 1>&2

	exit 10

fi


date_exec="$(which date 2>/dev/null)"

if [ ! -x "${date_exec}" ]; then

	echo " Error, no 'date' executable found." 1>&2

	exit 15

fi


# May be "DATE TIME":
new_timestamp="$*"

if [ $# -ge 3 ]; then

	echo " Error, extra argument(s) specified.
${usage}" 1>&2

	exit 20

fi


if [ -n "${new_timestamp}" ]; then

	printf "Setting localhost timestamp to '${new_timestamp}'\n"
	if ! "${date_exec}" -s "${new_timestamp}"; then

		echo " Error, setting of timestamp '${new_timestamp}' failed." 1>&2

		exit 30

	else

		echo "The '${new_timestamp}' timestamp has been successfully set."

	fi

else

	echo " Error, no timestamp specified.
${usage}" 1>&2

	exit 25

fi
