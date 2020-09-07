#!/bin/sh

usage="Usage: '$(basename $0) [-h|--help] DURATION', i.e. requests to trigger (indefinitely, just use CTRL-C to stop) a timer notification every DURATION, which is expressed as:
 MINUTES or MINUTES:SECONDS or HOURS:MINUTES:SECONDS
Will play bong each time the specified duration is elapsed; useful for example for exercising.
Ex: '$(basename $0) 20' will notify noisily every 20 minutes elapsed.
"


if [ "$1" = "-h" ] || [ "$1" = "--help" ]; then
	echo "$usage"
	exit
fi

duration_str="$1"

if [ -z "${duration_str}" ]; then

	echo "  Error, no periodical duration specified.
$usage" 1>&2
	exit 10

fi


timer_in_script_name="timer-in.sh"
timer_in_script=$(which ${timer_in_script_name} 2>/dev/null)

if [ ! -x "${timer_in_script}" ]; then

	echo "  Error, no executable '${timer_in_script_name}' script found." 1>&2
	exit 5

fi

if [ -z "$1" ]; then
	echo "  Error, no periodical duration specified.
$usage"
	exit 1
fi

extra=""

colon_count=$(echo "${duration_str}" | awk -F":" '{print NF-1}')
#echo "colon_count = ${colon_count}"

case $colon_count in

	0)
		extra="minutes"
		;;
	1)
		extra="(MM:SS)"
		;;

	2)
		extra="(HH:MM:SS)"
		;;

	*)
		echo "Invalid timestamp '${duration_str}'." 1>&2
		exit 20
		;;

esac

echo "  Will notify each time (and until end of time) that a duration of ${duration_str} ${extra} elapsed...."

while true; do

	${timer_in_script} ${duration_str} 1>/dev/null
	echo "(waiting again for ${duration_str})"

done
