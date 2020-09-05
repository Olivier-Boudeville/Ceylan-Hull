#!/bin/sh

usage="Usage: '$(basename $0) [-h|--help] TIMESTAMP', i.e. requests to trigger a timer notification at specified TIMESTAMP, which is expressed as HOURS:MINUTES or HOURS:MINUTES:SECONDS.
Will play bong when specified time is reached; useful typically to respect fixed schedules.
Ex: '$(basename $0) 12:05' will notify noisily once this time is reached.
See also: timer-in.sh for a timer based on a duration from current time rather than on an absolute timestamp."


if [ "$1" = "-h" ] || [ "$1" = "--help" ]; then
	echo "$usage"
	exit
fi


timer_in_script="timer-in.sh"

if [ ! -x "${timer_in_script}" ]; then

	echo "  Error, no executable '${timer_in_script}' script found." 1>&2
	exit 5

fi


if [ -z "$1" ]; then
	echo "  Error, no target timestamp specified.
$usage"
	exit 1
fi

target_timestamp="$1"
#echo target_timestamp="$target_timestamp"

# Current time, since the Epoch:
start_secs=$(date +%s)
#echo "start_secs = ${start_secs}"


# Let's count the colons to discriminate between MINUTES (0) / MINUTES:SECONDS
# (1) / HOURS:MINUTES:SECONDS (2):
#
colon_count=$(echo "${target_timestamp}" | awk -F":" '{print NF-1}')
#echo "colon_count = ${colon_count}"


if [ ! $colon_count -eq 1 ] &&  [ ! $colon_count -eq 2 ]; then

	echo "  Error, specified timestamp ('${target_timestamp}') is invalid." 1>&2
	exit 10

fi



# Mostly for checking:

#target_hours=$(echo "${target_timestamp}" | sed 's|:.*$||1')
#echo target_hours="$target_hours"

#if [ -z "${target_hours}" ]; then

#	echo "  Error, failed to parse hours in '${target_timestamp}' target timestamp." 1>&2
#	exit 10

#fi


#target_minutes=$(echo "${target_timestamp}" | sed 's|^.*:||1')
#echo target_minutes="$target_minutes"

#if [ -z "${target_minutes}" ]; then

#	echo "  Error, failed to parse minutes in '${target_timestamp}' target timestamp." 1>&2
#	exit 11

#fi

#finish_secs=$(date --date "${target_hours}:${target_minutes}" +%s)
finish_secs=$(date --date "${target_timestamp}" +%s)
#echo "finish_secs = ${finish_secs}"

diff_secs=$(expr ${finish_secs} - ${start_secs})
#echo "diff_secs = ${diff_secs}"

# For example if requesting a notification at 8:00 whereas current time is 17:00
# the day before:
#
# (number of seconds during a full day: 24*3600=86400)

if [ $diff_secs -lt 0 ]; then
	diff_secs=$(expr $diff_secs + 86400)
	#echo "offset diff_min = ${diff_min}"
fi

if [ $diff_secs -lt 0 ]; then
	echo "Error when determining duration (got $diff_secs seconds despite offset)."
	exit 50
fi

# Integer division:
diff_min=$(expr ${diff_secs} / 60)
#echo "diff_min = ${diff_min}"

# Preferring to be second-correct:
diff_min_as_secs=$(expr ${diff_min} \* 60 )
extra_secs=$(expr ${diff_secs} - ${diff_min_as_secs})

timer-in.sh ${diff_min}:${extra_secs}
