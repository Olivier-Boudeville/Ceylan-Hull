#!/bin/sh

usage="Usage: $(basename $0): updates the 'locate' database, for faster look-ups in filesystems."


updatedb_exec=$(which updatedb 2>/dev/null)

slocate_exec=/usr/bin/slocate
slocate_conf=/etc/updatedb.conf


if [ ! $(id -u) -eq 0 ]; then
	echo "Error, only root can do that."
	exit 1
fi


# Apparently the best approach now:
if [ -x "${updatedb_exec}" ]; then

	"${updatedb_exec}"

	exit

fi


# Otherwise:
if [ -x "${slocate_exec}" ]; then

	echo "Updating locate database..."

	if [ -f "${slocate_conf}" ]; then
		source ${slocate_conf}
		${slocate_exec} -u && echo "... done"
	else
		${slocate_exec} -f proc -u && echo "... done"
	fi
	chown root.slocate /var/lib/slocate/slocate.db

else
	echo "Error, no slocate tool found (no ${slocate_exec})."
	exit
fi
