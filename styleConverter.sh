#!/bin/sh

USAGE="`basename $0` <a file>: apply some change onto provided file"

TOOL=`which astyle 2>/dev/null`

if [ ! -f "$1" ] ; then
	echo "Error, no file to convert named $1. Usage: $USAGE"
fi


if [ ! -x "$TOOL" ] ; then
	echo "Error, no tool $TOOL available. Usage: $USAGE"
fi

echo "    Converting $1"

$TOOL <$1 >$1.tmp
mv $1.tmp $1

