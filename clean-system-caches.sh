#!/bin/sh

# Copyright (C) 2018-2026 Olivier Boudeville
#
# Author: Olivier Boudeville [olivier (dot) boudeville (at) esperide (dot) com]
#
# This file is part of the Ceylan-Hull toolbox (see http://hull.esperide.org).

usage="Usage: $(basename $0) [-h|--help] [-q|--quiet] [-e|--even-sync]: cleans system caches on Arch Linux, typically to try to save some space from cached and/or orphaned packages, from journalctl logs, etc.
 Options:
   -q or --quiet: quiet mode, outputs information iff an error occurred
   -e or --even-sync: removes also the existing Pacman sync files (useful if having mirror-related problems, like 'error: GPGME error: No data' or 'error: database 'xxx' is not valid'); then 'pacman -Syu' may be run, to restore the archlinux-keyring package and the database file for core and extra
"

if [ "$1" = "-h" ] || [ "$1" = "--help" ]; then

	echo "${usage}"

	exit 0

fi


quiet=1

if [ "$1" = "-q" ] || [ "$1" = "--quiet" ]; then
	quiet=0
	shift
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


pacman_exec="$(which pacman 2>/dev/null)"

if [ ! -x "${pacman_exec}" ]; then

	echo "  Error, no 'pacman' executable found. Is it really Arch Linux?" 1>&2

	exit 10

fi


journalctl_exec="$(which journalctl 2>/dev/null)"

if [ ! -x "${journalctl_exec}" ]; then

	echo "  Error, no 'journalctl' executable found." 1>&2

	exit 15

fi



if [ $(id -u) -eq 0 ]; then

	[ $quiet -eq 0 ] || printf " Cleaning system caches: full removal of the content of pacman cache...\n"

	# Note that the --noconfirm option would just apply the default answer,
	# which is "no" in some cases:
	#
	# """
	# :: Do you want to remove ALL files from cache? [y/N] y
	# :: Do you want to remove unused repositories? [Y/n] y
	#
	# So empty the whole pacman cache:
	#
	(yes | "${pacman_exec}" -Scc 1>/dev/null 2>&1) && ([ $quiet -eq 0 ] || printf "  ... pacman cache emptied!\n")

	if [ ${even_sync} -eq 0 ]; then
		/bin/rm -rf /var/lib/pacman/sync/
	fi


	[ $quiet -eq 0 ] || printf "\n Removing orphaned packages...\n"
	orphans="$(pacman -Qdtq)"

	if [ -n "${orphans}" ]; then
		(yes | "${pacman_exec}" -Rns ${orphans}) && ([ $quiet -eq 0 ] || printf "  ... orphaned packages removed!\n")
	else
		([ $quiet -eq 0 ] || printf "(no orphaned package to remove)\n")
	fi

	journalctl_max_size=250

	[ $quiet -eq 0 ] || printf "\n Vacuuming journatctl log size to ${journalctl_max_size} MB...\n"

	"${journalctl_exec}" -q --vacuum-size=${journalctl_max_size}M && ([ $quiet -eq 0 ] || printf "  ... journalctl logs vacuumed!\n")

	# Other possible culprits: applicative logs, OCI images in /var/lib/docker,
	# VMs, user archives, etc.

else

	echo "  Error, you must be root." 1>&2

	exit 50

fi
