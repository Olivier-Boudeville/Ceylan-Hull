#!/bin/sh


# Triggers the best 'top' available: triggers an appropriate tool to monitor
# processes and system resources.


atop=$(which atop 2>/dev/null)
#echo "atop = ${atop}"


args="$*"
#echo "args = ${args}"


if [ -x "${atop}" ] ; then

	#echo " (running ${atop})"
	${atop} ${args}

else

	#echo " (running top)"
	top

fi
