#!/bin/sh

usage="Usage: $(basename $0) [-h|--help]: locks immediately the screen."

# Logging to a console and executing 'killall xscreensaver' as your normal user
# might be your best friend, as at least sometimes correct logins are rejected
# and will lead to have one's account blocked for 10 minutes repeatedly...

# Consider also 'xfce4-session-logout --suspend' or 'systemctl suspend'.


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


echo "Activating the screensaver on $(date), and locking the screen immediately..."

${locker_name} -no-splash 1>/dev/null &

locker_cmd="xscreensaver-command"

${locker_cmd} -lock 1>/dev/null

echo "... unlocked on $(date)"
