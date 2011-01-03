#!/bin/sh

# Default: in English
# With the -f option: in French

# See also: newda script.


if [ "$1" = "-f" ] ; then

	LANG=fr_FR.UTF-8 date '+%A %-e %B %Y'

else

	LANG= date '+%A, %B %-e, %Y'

fi
