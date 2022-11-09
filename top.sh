#!/bin/sh

usage="  Usage: $(basename $0): triggers the best 'top' available: runs an appropriate tool to monitor processes and system resources.
Currently: htop preferred over atop preferred over classical top."

if [ "$1" = "-h" ] || [ "$1" = "--help" ]; then

	echo "${usage}"

	exit

fi


args="$*"
#echo "args = ${args}"

# Recreates more or less the usual top:
default_args=""


if [ -z "${args}" ]; then

	args="${default_args}"

fi


htop="$(which htop 2>/dev/null)"
#echo "htop = ${htop}"

if [ -z "${htop}" ]; then

	atop="$(which atop 2>/dev/null)"
	#echo "atop = ${atop}"

	if [ -z "${atop}" ]; then

		#echo " (running top)"

		# Expecting /bin/top:
		top="$(which top 2>/dev/null)"

		if [ -z "${top}" ]; then

			echo "  Error, no top-like tool found." 1>&2

			exit 15

		else

			top ${args}

		fi

	else

		if [ -z "${args}" ]; then

			# Defaults (1 update per second):
			args="1"

		fi

		echo " (running ${atop}; hit 'z' to pause, 'q' to exit)"
		${atop} ${args}

	fi

else

	# Selecting F6 ("SortBy") then PERCENT_CPU is often useful:
	${htop} ${args}

fi
