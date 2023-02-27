#!/bin/sh

# Default: in English.
# With the -f/-fr option: in French.

# See also: newda script.


if [ "$1" = "-f" ] || [ "$1" = "-fr" ]; then

	LC_ALL=fr_FR.UTF-8 date '+%A %-e %B %Y'

else

	LC_ALL= date '+%A, %B %-e, %Y'

fi
