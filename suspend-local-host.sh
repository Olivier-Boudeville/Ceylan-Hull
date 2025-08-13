#!/bin/sh

usage="Usage: $(basename $0) [-h|--help]: suspends immediately the local host, and ensures that it will resume in a locked state."


# On our Arch desktop that uses xfce4-screensaver, 'systemctl suspend' is
# sufficient for a proper suspend:
#
# - to be awoken once suspended by pressing shortly the user main ON button on
# the front of the computer case (hitting the keyboard having no effect)
#
# - with (1) a proper lock screen being displayed when returning from
# suspension, and (2) everything being then restored as normal, from OpenGL to
# the network
#
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


# If it had to be triggered explicitly:
# (not needed, at least if using Arch + xfce4-screensaver)
#
trigger_locker=1


# If using xscreensaver.
#
# Fails on our desktop Arch:
# xscreensaver: "xfce4-screensaver" is already running on display :0.0
# xscreensaver-command: no screensaver is running on display :0.0
#
use_xscreensaver()
{

	locker_activate_name="xscreensaver-command"
	locker_activate_needed=0

	locker_cmd_name="xscreensaver"
	locker_cmd_lock_opts="-lock" # "--no-splash"

}


actual_suspend()
{

	# 'systemctl hybrid-sleep' or 'systemctl suspend-then-hibernate' may fail
	# with "Call failed: Not enough suitable swap space for hibernation
	# available on compatible block devices and file systems"
	#
	systemctl suspend

}


# To avoid any disabling of the locker:
if ! gsettings set org.gnome.desktop.screensaver lock-enabled true; then

	echo "  Error, the locker could not be enabled." 1>&2
	exit 15

fi



if [ $trigger_locker -eq 0 ]; then

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

	locker_exec="$(which ${locker_name})"

	if [ ! -x "${locker_exec}" ]; then

		echo "  Error, no locker tool found ('${locker_name}')." 1>&2
		exit 15

	fi

	echo "Activating the screensaver on $(date) (based on '${locker_name}'), locking the screen immediately then requesting to suspend..."

	"${locker_exec}" ${locker_cmd_lock_opts} 1>/dev/null &

else

	echo "Suspending on $(date)..."

fi


actual_suspend


# Timestamp would not be updated yet (time jump):
#sleep 2
#echo "... awoken from locked suspend on $(date)"

echo "... awoken from locked suspend"
