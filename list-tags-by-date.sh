#!/bin/sh

usage="Usage: $(basename $0) [-h|--help]: lists, for the current VCS (Git) repository, all (annotated) tags, from the oldest one to the latest one.

For example:
 Tag refs/tags/debug.1.0.0 was set on Thu Jul 6 13:24:01 2023 +0200
 Tag refs/tags/some_fix was set on Mon Sep 25 18:11:23 2023 +0200
"


if [ "$1" = "-h" ] || [ "$1" = "--help" ]; then

	echo "${usage}"
	exit 0

fi

echo "  Listing repository tags, from oldest to newest:"

# Removing empty lines:
#git for-each-ref --sort=taggerdate --format '%(tag)' | sed '/^[[:space:]]*$/d'

git for-each-ref --sort=creatordate --format 'Tag %(refname) was set on %(creatordate)' refs/tags
