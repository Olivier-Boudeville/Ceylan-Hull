#!/bin/sh

usage="Usage: $(basename $0) [-h|--help]: lists, for the current VCS (GIT) repository, all (annotated) tags, from the oldest one to the latest one."


if [ "$1" = "-h" ] || [ "$1" = "--help" ]; then

	echo "${usage}"
	exit 0

fi

echo "  Listing repository tags, from oldest to newest:"

# Removing empty lines:
git for-each-ref --sort=taggerdate --format '%(tag)' | sed '/^[[:space:]]*$/d'
