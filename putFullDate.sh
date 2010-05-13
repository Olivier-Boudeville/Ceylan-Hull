#!/bin/sh

# Default: in English
# With the -f option: in French

# See also: newda script.


if [ "$1" = "-f" ] ; then

	export LANG=fr_FR@euro
	date '+%A %-e %B %Y'

else

	export LANG=
	date '+%A, %B %-e, %Y'

fi
