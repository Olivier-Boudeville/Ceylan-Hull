#!/bin/sh

SLOCATE_EXE=/usr/bin/slocate
SLOCATE_CONF=/etc/updatedb.conf

if [ ! `id -u` == "0" ] ; then
	echo "Error, only root can do that."
	exit
fi 

if [ -x "$SLOCATE_EXE" ]; then

	echo "Updating locate database..."

	if [ -f "$SLOCATE_CONF" ]; then
		source $SLOCATE_CONF
		$SLOCATE_EXE -u && echo "... done"
	else
		$SLOCATE_EXE -f proc -u && echo "... done"
	fi
	chown root.slocate /var/lib/slocate/slocate.db

else
	echo "Error, no slocate tool found (no $SLOCATE_EXE)."
	exit
fi


