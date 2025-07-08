#!/bin/sh

usage="Usage: $(basename $0) [-h|--help]: locks immediately the screen."

# Logging to a console and executing 'killall xscreensaver' as your normal user
# might be your best friend, as at least sometimes with this tool correct logins
# are rejected and will lead to have one's account being blocked for 10 minutes
# repeatedly...

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


# If using xscreensaver-command:
use_xscreensaver()
{

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
	locker_cmd_name="xscreensaver-command"

	locker_cmd_lock_opts="-lock"
	locker_activate_needed=0

}


# If using gnome-screensaver-command:
use_gnome_screensaver()
{

	# Never did anything on our Arch (no daemon launched?):
	locker_activate_name="gnome-screensaver-command"
	locker_activate_needed=0

	locker_cmd_name="${locker_activate_name}"

}


# If using xlock (install the 'xlockmore' Arch package):

use_xlock()
{

	locker_activate_name="xlock"
	locker_activate_needed=1

	locker_cmd_name="${locker_activate_name}"

	locker_cmd_lock_opts="-mode blank"
	#locker_cmd_lock_opts="-mode marquee"
	#locker_cmd_lock_opts="-mode flag"
	#locker_cmd_lock_opts="-mode nose"

}


# If using xdg-screensaver; nowadays quite often the best (most general) option,
# yet not wanting, at least on my Arch:
#
# $ xdg-screensaver lock
# ERROR: Unknown command 'lock'
#
use_xdg_screensaver()
{

	locker_activate_name="xdg-screensaver"
	locker_activate_needed=1

	locker_cmd_name="${locker_activate_name}"
	locker_cmd_lock_opts="lock"

}


# To avoid any disabling of the locker:
if ! gsettings set org.gnome.desktop.screensaver lock-enabled true; then

	echo "  Error, the locker could not be enabled." 1>&2
	exit 15

fi


distro="$(grep '^ID' /etc/os-release | sed 's|^ID=||')"

if [ "${distro}" = "arch" ]; then
	use_xlock
else
	use_xdg_screensaver
fi



if [ $locker_activate_needed -eq 0 ]; then

	# First launching any screensaver daemon, if needed (possibly optional
	# step):
	#
	if [ -n "${locker_activate_name}" ]; then

		locker_activate_exec="$(which ${locker_activate_name})"

		if [ ! -x "${locker_activate_exec}" ]; then

			echo "  Error, no locker daemon found ('${locker_activate_name}')." 1>&2
			exit 5

		fi

		echo "Activating first the screensaver"

		"${locker_activate_exec}" ${locker_activate_opts} 1>/dev/null &

	else

		echo "Error, locker activation needed when no name specified for it." 1>&2

		exit 50

	fi

fi


locker_cmd_exec="$(which ${locker_cmd_name})"

if [ ! -x "${locker_cmd_exec}" ]; then

	echo "  Error, no locker command found ('${locker_activate_name}')." 1>&2
	exit 15

fi


# Then activate the locker itself:

echo "Locking the screen immediately (with ${locker_cmd_name}) on $(date)..."

# Not run in the background anymore (no trailing '&)', so that any wrapping
# script (e.g. leaving-home.sh) can itself be synchronised on locking/unlocking;
# however with xscreensaver it is never blocking actually...
#
# At least most blockers are, unsurprisingly, blocking:
"${locker_cmd_exec}" ${locker_cmd_lock_opts} 2>/dev/null
# 1>/dev/null 2>&1

echo "... unlocked on $(date)"
