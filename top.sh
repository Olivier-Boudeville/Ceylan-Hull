#!/bin/sh


# Best 'top' available: triggers an appropriate tool to monitor processes and
# system resources.


atop=$(which atop)
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
