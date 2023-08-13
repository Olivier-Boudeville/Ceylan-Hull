#!/bin/sh

# Awful PGP support:
target_client="thunderbird"

# Constant problems with at least some IMAP servers:
#target_client="evolution"


usage="Usage: $(basename $0): launches a relevant (${target_client}) email client."

if [ ! $# -eq 0 ]; then

	echo "   Error, no parameter is to be specified to this script.
${usage}" 1>&2
	exit 4

fi


# May be useful/needed, for example to have proper date/time formats whereas the
# system uses other settings:
#
export LC_ALL=fr_FR.UTF-8


if [ "${target_client}" = "thunderbird" ]; then

	# We recommend using the "DKIM Verifier" plugin.

	thunderbird 1>/dev/null 2>&1 &

elif [ "${target_client}" = "evolution" ]; then

	evolution 1>/dev/null 2>&1 &

else

	echo "  Error, target client '${target_client}' not supported." 1>&2
	exit 5

fi
