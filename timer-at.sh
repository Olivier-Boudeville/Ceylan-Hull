#!/bin/sh

usage="Usage: $(basename $0) [-h|--help] [-s|--silent] TIMESTAMP [ MESSAGE | [ TITLE | MESSAGE ] ]', i.e. requests to trigger a timer notification (based on MESSAGE, if specified; possibly with a TITLE) at specified TIMESTAMP, which is expressed as HOURS:MINUTES (e.g. 17:02) or HOURS:MINUTES:SECONDS (e.g. 17:02:31); note that timestamps of the form HOURShMINUTES (e.g. 17h02) and HOURShMINUTESmSECONDS (e.g. 17h02m31) are supported as well.

Will issue such a notification when the specified time is reached; useful typically to respect fixed schedules.

The silent mode enables only the graphical notifications (useful in a train for example).

For example: '$(basename $0) 12:05' will notify noisily once this time is reached.

See also: timer-in.sh for a timer based on a duration from current time, rather than on an absolute timestamp."


if [ "$1" = "-h" ] || [ "$1" = "--help" ]; then
	echo "${usage}"
	exit
fi


be_silent=1
silent_opt=""

if [ "$1" = "-s" ] || [ "$1" = "--silent" ]; then
	shift
	# Will be displayed by the called script: echo "(silent mode activated)"
	be_silent=0
	silent_opt="--silent"
fi


timer_in_script_name="timer-in.sh"
timer_in_script="$(which ${timer_in_script_name} 2>/dev/null)"

if [ ! -x "${timer_in_script}" ]; then
	echo "  Error, no executable '${timer_in_script_name}' script found." 1>&2
	exit 5
fi


if [ -z "$1" ]; then
	echo "  Error, no target timestamp specified.
${usage}"
	exit 1
fi


target_timestamp="$1"
#echo target_timestamp="$target_timestamp"


# Current time, since the Epoch:
start_secs="$(date +%s)"
#echo "start_secs = ${start_secs}"


# In addition to 15:07:32, 15h07m32 is supported:
target_timestamp=$(echo ${target_timestamp} | tr 'h' ':' | tr 'm' ':')

# Let's count the colons to discriminate between MINUTES (0) / MINUTES:SECONDS
# (1) / HOURS:MINUTES:SECONDS (2):
#
colon_count=$(echo "${target_timestamp}" | awk -F":" '{print NF-1}' 2>/dev/null)
#echo "colon_count = ${colon_count}"


if [ ! ${colon_count} -eq 1 ] && [ ! ${colon_count} -eq 2 ]; then

	echo "  Error, specified timestamp ('${target_timestamp}') is invalid.
${usage}" 1>&2
	exit 10

fi



# For checking:

target_hours=$(echo "${target_timestamp}" | sed 's|:.*$||1')
#echo target_hours="${target_hours}"

if [ -z "${target_hours}" ]; then

	echo "  Error, failed to parse hours in '${target_timestamp}' target timestamp.
${usage}" 1>&2
	exit 10

fi


target_minutes=$(echo "${target_timestamp}" | sed 's|^.*:||1')
#echo target_minutes="${target_minutes}"

if [ -z "${target_minutes}" ]; then

	echo "  Error, failed to parse minutes in '${target_timestamp}' target timestamp.
${usage}" 1>&2
	exit 11

fi

#echo "date for finish_secs: ${target_hours}:${target_minutes}"
#finish_secs=$(date --date "${target_hours}:${target_minutes}" +%s)

finish_secs=$(date --date "${target_timestamp}" +%s 2>/dev/null)
#echo "finish_secs = ${finish_secs}"

if [ -z "${finish_secs}" ]; then
	echo "  Error when determining finishing seconds.
${usage}" 1>&2
	exit 50
fi

diff_secs="$(expr ${finish_secs} - ${start_secs} 2>/dev/null)"
#echo "diff_secs = ${diff_secs}"

if [ -z "${diff_secs}" ]; then
	echo "  Error when subtracting seconds.
${usage}" 1>&2
	exit 55
fi

# For example if requesting a notification at 8:00 whereas current time is 17:00
# the day before:
#
# (number of seconds during a full day: 24*3600=86400)

if [ ${diff_secs} -lt 0 ]; then
	diff_secs="$(expr $diff_secs + 86400 2>/dev/null)"
	#echo "offset diff_min = ${diff_min}"
fi

if [ $diff_secs -lt 0 ]; then
	echo "  Error when determining duration (got ${diff_secs} seconds despite offset).
${usage}" 1>&2
	exit 60
fi

# Integer division:
diff_min="$(expr ${diff_secs} / 60 2>/dev/null)"
#echo "diff_min = ${diff_min}"

# Preferring to be second-correct:
diff_min_as_secs="$(expr ${diff_min} \* 60 2>/dev/null)"
extra_secs="$(expr ${diff_secs} - ${diff_min_as_secs} 2>/dev/null)"

#echo ${timer_in_script} ${diff_min}:${extra_secs}
${timer_in_script} ${silent_opt} "${diff_min}:${extra_secs}" "$2" "$3"
