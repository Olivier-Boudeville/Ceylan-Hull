#!/bin/sh

usage="Usage: $(basename $0) [-h|--help] [-f|--force-enabled]: toggles the touchpad activation state.

Note that sometimes some touchpads may be stuck in disabled state. In this case one may try to force their enabling thanks to the -f / --force-enabled option. Other possibilities are to use instead any available trackpoint (generally never disabled) or to switch to a text console and come back to graphical mode, and hope for the best.
"

if [ "$1" = "-h" ] || [ "$1" = "--help" ]; then

	echo "${usage}"
	exit

fi


secure_synclient()
{

	client="$(which synclient 2>/dev/null)"

	if [ ! -x "${client}" ]; then

		echo "  Error, no 'synclient' executable found." 1>&2
		exit 20

	fi

}



if [ "$1" = "-f" ] || [ "$1" = "--force-enabled" ]; then

	secure_synclient
	${client} TouchpadOff=0
	exit $?

fi


if [ "$1" ]; then

	echo "  Error, extra parameter specified.
${usage}" 1>&2

	exit 5

fi



use_synclient()
{

	secure_synclient

	# Quick and dirty, yet working:
	if ${client} -l | grep TouchpadOff | grep '= 1' 1>/dev/null; then

		# On some computers, this may be reported as succeeded, whereas not
		# being actually enabled again:
		#
		if ${client} TouchpadOff=0; then

			echo "Touchpad enabled."

		else

			echo "  Error, touchpad enabling reported as failed." 1>&2
			exit 25

		fi

	elif ${client} -l | grep TouchpadOff | grep '= 0' 1>/dev/null; then

		if ${client} TouchpadOff=1; then

			# Apparently reliable:
			echo "Touchpad disabled."

		else

			echo "  Error, touchpad disabling reported as failed." 1>&2
			exit 28

		fi

	else

		echo "Error, could not interpret touchpad state with synclient." 1>&2
		exit 29

	fi

}


use_xinput()
{

	xinput="$(which xinput 2>/dev/null)"

	if [ ! -x "${xinput}" ]; then

		echo "  Error, no 'xinput' executable found." 1>&2
		exit 50

	fi

	#touchpad_id=$(${xinput} | grep -i touchpad | cut -f2 | cut -d '=' -f2)
	touchpad_id="$(${xinput} --list | grep -i touchpad | sed 's|^.*id=||1' | awk '{print $1}')"
	#echo "touchpad_id = ${touchpad_id}"

	is_enabled="$(${xinput} list-props "${touchpad_id}" | grep 'Device Enabled' | grep -o "[01]$")"
	#echo "is_enabled = ${is_enabled}"

	if [ "${is_enabled}" = "0" ]; then

		# Obtained with: xinput --list-props "${touchpad_id}"
		#${xinput} --set-prop ${touchpad_id} 'Device Enabled' 1

		# Simpler:
		if ${xinput} --enable ${touchpad_id}; then

			echo "Touchpad enabled."

		else

			echo "  Error, touchpad enabling reported as failed." 1>&2
			exit 55

		fi

	elif [ "${is_enabled}" = "1" ]; then

		if ${xinput} --disable ${touchpad_id}; then

			echo "Touchpad disabled."

		else

			echo "  Error, touchpad disabling reported as failed." 1>&2
			exit 58

		fi

	else

		echo "Error, could not interpret touchpad state with xinput." 1>&2
		exit 59

	fi

}


# At least with some Thinkpad laptops, neither synclient nor xinput will work,
# but the trackpoint is likely to remain fully operation in all cases.

#use_synclient

# Synclient not working properly (enabling not actually done) at least with
# Gnome, so:
#
use_xinput
