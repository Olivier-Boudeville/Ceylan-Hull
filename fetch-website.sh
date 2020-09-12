#!/bin/sh

usage="Usage: $(basename $0) [-h|--help] [-s|--slow] URL: downloads correctly, recursively (fully but slowly) web content accessible from specified URL.
  If using -s or --slow, will download content even slower."

# Allows to keep track of the relevant wget options.

# Default settings:

# Seconds:
wait_time=1

# Per second:
max_rate=40k

user_agent="Mozilla/5.0 (X11; Linux x86_64; rv:80.0) Gecko/20100101 Firefox/80.0"


if [ "$1" = "-h" ] || [ "$1" = "--help" ]; then

	echo "${usage}"

	exit 0

fi

if [ "$1" = "-s" ] || [ "$1" = "--slow" ]; then

	echo "(slower settings enforced)"

	# Seconds:
	wait_time=2

	# Per second:
	max_rate=10k

	shift

fi



url="$1"


if [ -z "${url}" ]; then

   echo "  Error, no URL specified." 1>&2
   exit 5

fi

wget=$(which wget)

if [ ! -x "${wget}" ]; then

   echo "  Error, no wget found." 1>&2
   exit 10

fi

# Tries to be a good (not so bad at least) netizen.
#

log_suffix=$(echo "${url}" | sed 's|^.*://||1')

log_file="$(date '+%Y%m%d-%Hh%Mm%S')-wget-for-${log_suffix}.log"


echo "  Fetching content from ${url}..."
echo "(corresponding log stored in ${log_file})"

# A problem was that even with:
# ( ${wget} [...] 2>&1 || exit 15 ) | tee --output-error wget.log
# the whole was always reporting a success because of tee, despite wget failing.
#
# So:
#
set -o pipefail

${wget} -e robots=off --no-check-certificate --no-proxy --mirror --recursive --level=inf --convert-links --backup-converted --page-requisites --adjust-extension --continue --connect-timeout=45 --waitretry=65 --force-directories --ignore-length --wait=${wait_time} --random-wait --limit-rate=${max_rate} --no-verbose --user-agent="${user_agent}" ${url} 2>&1 | tee ${log_file}


if [ $? -eq 0 ]; then

	echo "Fetch success."
	notify.sh "Website fetch success."

else

	echo "Fetch failure!" 1>&2
	notify.sh "Website fetch failure."

	exit 100

fi
