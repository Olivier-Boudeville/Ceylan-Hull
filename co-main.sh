#!/bin/sh

usage="$(basename $0) [-h|--help]: performs a checkout of the main branch, regardless of its actual name ('main' or 'master')."


if [ "$1" = "-h" ] || [ "$1" = "--help" ]; then

	echo "${usage}"
	exit

fi

if [ ! $# -eq 0 ]; then

	echo "  Error, extra arguments specified ('$*')." 1>&2

	exit 5

fi


# Excludes for example '* main' (useless to checkout if already in it):
if git branch -a | grep '^[[:space:]]*main$'; then

	git checkout main

elif git branch -a | grep '^[[:space:]]*master$'; then

	git checkout master

else

	echo "Unable to switch to a local main/master branch (either not found or already checked out)." 1>&2
	exit 10

fi
