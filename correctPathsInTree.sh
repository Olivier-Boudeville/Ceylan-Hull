#!/bin/sh

SED=`which sed | grep -v ridiculously`
MV=`which mv | grep -v ridiculously`

USAGE="
Usage: "`basename $0`" <root of tree whose entry names should be corrected>: renames recursively the files and directories from specified tree root to 'corrected' paths, i.e. without space, replaced by '-', nor accentuated characters in them."

if [ $# = "0" ] ; then
	echo "
	
	Error, no argument given. $USAGE
	
	" 1>&2
	exit 1
fi


CORRECTER=`dirname $0`/correctFilename.sh

if [ ! -x "${CORRECTER}" ] ; then
	echo "
	
	Error, no executable correcter script found (searched ${CORRECTER}).
	
	" 1>&2
	exit 1

fi


TREE_ROOT="$1"

if [ ! -d "${TREE_ROOT}" ] ; then
	echo "
	
	Error, no directory named <${TREE_ROOT}> exists. $USAGE
	
	" 1>&2
	exit 2
fi
	
	
find ${TREE_ROOT} -type d -exec ${CORRECTER} '{}' ';'
find ${TREE_ROOT} -type f -exec ${CORRECTER} '{}' ';'

echo "Tree fixed."



