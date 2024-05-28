#!/bin/sh

usage="Usage: $(basename $0) [-h|--help] [-l|--local] [-r|--remote]: lists, assuming to be in a clone, the VCS branches from the most recently modified one to the ones that were modified a longer time ago.

Options:
  - '-l' / '--local': for local branches (the default)
  - '-r' / '--remote': for remote branches
"


if [ "$1" = "-h" ] || [ "$1" = "--help" ]; then

	echo "${usage}"

	exit

fi


# 1: local branches
# 2: remote branches

selected=1

if [ "$1" = "-l" ] || [ "$1" = "--local" ]; then
	selected=1
	shift
fi


if [ "$1" = "-r" ] || [ "$1" = "--remote" ]; then
	selected=2
	shift
fi

if [ ! $# -eq 0 ]; then

	echo "  Error, extra arguments specified.
${usage}" 1>&2
	exit 5

fi


case $selected in

	1)
		desc="local"
		targets=heads
		;;

	2)
		desc="remote"
		targets=remotes
		;;

esac


echo "Listing the ${desc} branches from the most recently modified one to the ones that were modified a longer time ago:"

git for-each-ref --sort='-committerdate:iso8601' --format=' %(committerdate:iso8601)%09%(refname)' refs/${targets}
