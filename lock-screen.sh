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


## If using xscreensaver:

# Non-blocking locking (script not stopped):
#locker_activate_name="xscreensaver"
#locker_activate_opts="-no-splash"

# Locking is done asynchronously, the command returns immediately.
#
# To detect the unlocking, the following approaches did not work for us:
# - gdbus monitor -y -d org.freedesktop.login1 | grep LockedHint
#
# - dbus-monitor --session "type='signal',interface='org.gnome.ScreenSaver'"
# (of course, as not using Gnome)
#
#locker_cmd_name="xscreensaver-command"
#locker_cmd_lock_opts="-lock"


# Never did anything on our Arch (no daemon launched?):
#locker_cmd_name="gnome-screensaver-command"


## If using xlock (install the 'xlockmore' Arch package):

# Nothing needed:
locker_activate_name=""
locker_activate_opts=""

locker_cmd_name="xlock"

locker_cmd_lock_opts="-mode blank"
#locker_cmd_lock_opts="-mode marquee"
#locker_cmd_lock_opts="-mode flag"
#locker_cmd_lock_opts="-mode nose"


# First launching the screensaver daemon, if needed (possibly optional step):
if [ -n "${locker_activate_name}" ]; then

	locker_activate_exec="$(which ${locker_activate_name})"

	if [ ! -x "${locker_activate_exec}" ]; then

		echo "  Error, no locker daemon found ('${locker_activate_name}')." 1>&2
		exit 5

	fi

	echo "Activating first the screensaver"

	${locker_activate_exec} ${locker_activate_opts} 1>/dev/null &

fi


locker_cmd_exec="$(which ${locker_cmd_name})"

if [ ! -x "${locker_cmd_exec}" ]; then

	echo "  Error, no locker command found ('${locker_activate_name}')." 1>&2
	exit 15

fi


# Then activate the locker itself:

echo "Locking the screen immediately on $(date)..."

# Not run in the background anymore (no trailing '&)', so that any wrapping
# script (e.g. leaving-home.sh) can itself be synchronised on locking/unlocking;
# however with xscreensaver it is never blocking actually...
#
${locker_cmd_exec} ${locker_cmd_lock_opts} 1>/dev/null 2>/dev/null

echo "... unlocked on $(date)"
