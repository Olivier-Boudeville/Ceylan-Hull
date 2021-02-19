#!/bin/sh

usage="$(basename $0) <a file>: applies some style change to specified file"

TOOL=$(which astyle 2>/dev/null)

if [ ! -f "$1" ] ; then
	echo "Error, no file to convert named $1. Usage: ${usage}"
fi


if [ ! -x "$TOOL" ] ; then
	echo "Error, no tool $TOOL available. Usage: ${usage}"
fi

echo "    Converting $1"

$TOOL <$1 >$1.tmp
mv $1.tmp $1
