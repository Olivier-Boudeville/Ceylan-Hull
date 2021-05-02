#!/bin/sh

usage="$(basename $0) [HOST] : sets the X display to specified host; if none is specified, sets it to the local one."

if [ -z "$1" ]; then

	echo "Setting display to localhost."
	export DISPLAY=:0.0

else

	echo "Setting display to host '$1'."
	export DISPLAY="$1":0.0

fi
