#!/bin/sh

usage="Usage: $(basename $0) <root of tree whose entry names should be corrected>: renames recursively the files and directories from specified tree root to 'corrected' paths, i.e. without space (replaced with '-'), nor accentuated characters in them, etc.
Note: this script might have to be run more than once so that the names of all directories and files are full fixed."


if [ ! $# -eq 1 ]; then

	echo "  Error, exactly one parameter expected.
  ${usage}
	" 1>&2
	exit 5

fi


correcter_script=$(dirname $0)/fix-filename.sh

if [ ! -x "${correcter_script}" ]; then
	echo "

	Error, no executable correcter script found (searched ${correcter_script}).

	" 1>&2
	exit 10

fi


tree_root="$1"

if [ ! -d "${tree_root}" ]; then
	echo "
  Error, no directory named <${tree_root}> exists.
  ${usage}
	" 1>&2
	exit 15
fi

echo "  Fixing all paths in tree '$(realpath ${tree_root})'..."

# A problem is that renaming a base directory while iterating in it would result
# in faulty subpaths to be searched afterwards (a solution being then to run
# that script more than once).
#
# Instead a "depth-first" traversal is done; it is not sufficient yet so we
# perform multiple traversals:
#
find "${tree_root}" -depth -type d -exec ${correcter_script} '{}' ';'
find "${tree_root}" -depth -type d -exec ${correcter_script} '{}' ';'
find "${tree_root}" -depth -type d -exec ${correcter_script} '{}' ';'

find "${tree_root}" -type f -exec ${correcter_script} '{}' ';'

echo "  Tree fixed."
