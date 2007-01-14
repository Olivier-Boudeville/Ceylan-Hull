#!/bin/sh

USAGE="`basename $0` <hostname where to display X>"

if [ -z "$1" ]; then
	echo "Error, $USAGE"
	exit 1
fi

echo "Setting display to $1"
export DISPLAY="$1":0.0
