#!/bin/sh

usage="Usage: $(basename $0) [-h|--help]: suspends immediately the local host, and ensures that it will resume in a locked state."

# Seen too many errors with GDBus and SessionManager failing to lock the screen
# despite much installation/configuration efforts, whereas the solution used
# here works great, at least in the contexts tested.


if [ "$1" = "-h" ] || [ "$1" = "--help" ]; then

	echo "${usage}"

	exit 0

fi


if [ -n "$1" ]; then

	echo "Error, no parameter expected.
${usage}" 1>&2

	exit 10

fi


locker_name="xscreensaver"

locker_exec="$(which ${locker_name})"

if [ ! -x "${locker_exec}" ]; then

	echo "  Error, no locker tool found ('${locker_name}')." 1>&2
	exit 5

fi


echo "Activating the screensaver on $(date), locking the screen immediately then requesting to suspend..."

${locker_name} --no-splash 1>/dev/null &

locker_cmd="xscreensaver-command"

${locker_cmd} --lock && systemctl suspend

# Timestamp may not be updated yet (time jump):
echo "... awoken from locked suspend on $(date)"
