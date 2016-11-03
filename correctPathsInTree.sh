#!/bin/sh

SED=$(which sed | grep -v ridiculously)
MV=$(which mv | grep -v ridiculously)

USAGE="Usage: $(basename $0) <root of tree whose entry names should be corrected>: renames recursively the files and directories from specified tree root to 'corrected' paths, i.e. without space, replaced by '-', nor accentuated characters in them."

if [ ! $# -eq 1 ] ; then

	echo "  Error, exactly one parameter expected.
  $USAGE
	" 1>&2
	exit 1

fi


CORRECTER=$(dirname $0)/correctFilename.sh

if [ ! -x "${CORRECTER}" ] ; then
	echo "

	Error, no executable correcter script found (searched ${CORRECTER}).

	" 1>&2
	exit 1

fi


TREE_ROOT="$1"

if [ ! -d "${TREE_ROOT}" ] ; then
	echo "
  Error, no directory named <${TREE_ROOT}> exists.
  $USAGE
	" 1>&2
	exit 2
fi

# A problem is that renaming a base directory while iterating in it would result
# in faulty subpaths to be searched afterwards (a solution being then to run
# that script more than once). Instead a "depth-first" traversal is done:
#
find "${TREE_ROOT}" -depth -type d  -exec ${CORRECTER} '{}' ';'
find "${TREE_ROOT}" -type f -exec ${CORRECTER} '{}' ';'

echo "Tree fixed."
