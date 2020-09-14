#!/bin/sh

# If testing:
period="0:4"

# Default (30 minutes):
period="30"


usage="Usage: '$(basename $0) [-h|--help] [PERIOD]', starts a jam session interrupted every period (default: ${period})."


if [ "$1" = "-h" ] || [ "$1" = "--help" ]; then
	echo "$usage"
	exit
fi

if [ -n "$1" ]; then
	period="$1"
fi
	
timer_every_script_name="timer-every.sh"
timer_every_script=$(which ${timer_every_script_name} 2>/dev/null)

if [ ! -x "${timer_every_script}" ]; then

	echo "  Error, no executable '${timer_every_script_name}' script found." 1>&2
	exit 5

fi


echo "##### Starting now a jam session, interrupted every period of ${period} to take a break..."
echo

"${timer_every_script}" "${period}" "Stand up" "Let's take some exercise, my dear fellow!"
