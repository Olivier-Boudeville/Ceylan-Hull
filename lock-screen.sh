#!/bin/sh

usage="Usage: $(basename $0): locks immediately the screen."

# Logging to a console and executing 'killall xscreensaver' as your normal user
# might be your best friend, as at least sometimes correct logins are rejected
# and will lead to have one's account blocked for 10 minutes repeatedly...


locker_name="xscreensaver"

locker_exec="$(which ${locker_name})"

if [ ! -x "${locker_exec}" ]; then

	echo "  Error, no locker tool found ('${locker_name}')." 1>&2
	exit 5

fi


echo "Activating the screensaver, and locking the screen immediately..."

${locker_name} -no-splash 1>/dev/null &

locker_cmd="xscreensaver-command"

${locker_cmd} -lock 1>/dev/null
