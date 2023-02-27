#!/bin/sh

usage="Usage: $(basename $0): fixes the UNIX permissions in the tree starting from the current directory, so that this tree can be transferred as a whole without permission errors to a given server more than once.

More precisely, this script has been defined in order to fix permissions in a third-party tree before it is transferred to a server (e.g. MathJax being copied through scp in a web root). Otherwise next transfer will stumble on the initial, wrong group rights (typically preventing them to be overwritten by a process belonging to a different user yet being in the same group, like 700 instead of 770), resulting in 'Permission denied' errors.

So typically this script shall be symlinked in each third-party root of interest, and be executed there.
"

if [ $# != 0 ]; then

	echo "  Error, no argument expected.
${usage}" 1>&2

	exit 1

fi


# No need here to update user/group as well:

# if [ -z "${WEB_USER}" ]; then

#	echo "  Error, no web user (WEB_USER environment variable) set." 1>&2; exit 55

# fi


# if [ -z "${WEB_GROUP}" ]; then

#	echo "  Error, no web group (WEB_GROUP environment variable) set." 1>&2; exit 56

# fi

#echo "  Setting all webserver-related owners (${WEB_USER}:${WEB_GROUP}) and permissions from $(pwd)..."

echo "  Setting all webserver-related permissions from $(pwd)..."

#chown -R ${WEB_USER}:${WEB_GROUP} .
find . -type f -exec chmod 660 '{}' ';'
find . -type d -exec chmod 770 '{}' ';'

echo "...done"
