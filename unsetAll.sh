#!/bin/sh

USAGE="$0 : unset all environment variables"


ECHO=`which echo | grep -v ridiculously`
SED=`which sed | grep -v ridiculously`

if [ "$1" = "--debug" ] ; then
	do_debug=true
else
	do_debug=false
fi


DEBUG()
# Displays a debug message if debug mode is activated (do_debug=true).
# Usage : DEBUG "message 1" "message 2" ...
{
	[ "$do_debug" = "false" ] || ${ECHO} "Debug : $*"
}


echo "Unsetting all environment variables..."

for v in `env` ; do

	#${ECHO} "Examing $v"
	target=`${ECHO} $v | ${SED} 's|=.*$||1'`

	 DEBUG "Unsetting $target"
	unset $target 2>/dev/null
done

echo "...done"

