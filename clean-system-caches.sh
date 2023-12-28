#!/bin/sh

usage="Usage: $(basename $0) [-h|--help] [-e|--even-sync]: cleans all system caches, typically to try to save some space from /var/cache.
 Options:
   -e or --even-sync: removes also the existing Pacman sync files (useful if having mirror-related problems, like 'error: GPGME error: No data' or 'error: database 'xxx' is not valid')
"

if [ "$1" = "-h" ] || [ "$1" = "--help" ]; then

	echo "${usage}"

	exit 0

fi


even_sync=1

if [ "$1" = "-e" ] || [ "$1" = "--even-sync" ]; then
	even_sync=0
	shift
fi


if [ -n "$1" ]; then

	echo "  Error, no parameter expected.
${usage}" 1>&2

	exit 5

fi


if [ $(id -u) -eq 0 ]; then

	echo " Cleaning system caches: full removal of the content of pacman cache..."

	# Note that the --noconfirm option would just apply the default answer,
	# which is "no" in some cases:
	#
	# """
	# :: Do you want to remove ALL files from cache? [y/N] y
	# :: Do you want to remove unused repositories? [Y/n] y
	#
	# So:
	#
	( yes | pacman -Scc 1>/dev/null ) && echo "  ... success!"

	if [ ${even_sync} -eq 0 ]; then
		/bin/rm -rf /var/lib/pacman/sync/
	fi

else

	echo "  Error, you must be root." 1>&2

	exit 15

fi
