#!/bin/sh

LOCKER_NAME="xscreensaver"

LOCKER_EXEC=`which $LOCKER_NAME`

if [ ! -x "${LOCKER_EXEC}" ] ; then

	echo "  Error, no locker tool found ($LOCKER_NAME)" 1>&2
	exit 5

fi


echo "Activating the screen saver, and locking the screen immediately..."

xscreensaver -no-splash 1>/dev/null &

xscreensaver-command -lock 1>/dev/null


