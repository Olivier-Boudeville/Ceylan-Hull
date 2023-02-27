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


if [ "${target_client}" = "thunderbird" ]; then

	thunderbird 1>/dev/null 2>&1 &

elif [ "${target_client}" = "evolution" ]; then

	evolution 1>/dev/null 2>&1 &

else

	echo "  Error, target client '${target_client}' not supported." 1>&2
	exit 5

fi
