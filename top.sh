#!/bin/sh


# Triggers the best 'top' available: triggers an appropriate tool to monitor
# processes and system resources.

# Currently: htop preferred over atop preferred over classical top.

args="$*"
#echo "args = ${args}"

# Recreates more or less the usual top:
default_args=""


if [ -z "${args}" ]; then

	args="${default_args}"

fi


htop=$(which htop 2>/dev/null)
#echo "htop = ${htop}"

if [ -z "${htop}" ]; then

	atop=$(which atop 2>/dev/null)
	#echo "atop = ${atop}"

	if [ -z "${atop}" ]; then

		#echo " (running top)"
		top ${args}

	else

		#echo " (running ${atop})"
		${atop} ${args}

	fi

else

	${htop} ${args}

fi
