#!/bin/sh

# Default: in English
# With the -f option: in French

# See also: fuda script.


if [ "$1" = "-f" ] ; then

	LANG=fr_FR.UTF-8 date '+%Y, %B %e, %A'

else

	LANG= date '+%Y, %B %e, %A'

fi
