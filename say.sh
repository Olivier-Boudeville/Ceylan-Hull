#!/bin/sh

usage="Usage: ${basename} [-d|--display] TEXT: says specified text, based on text to speech.
 -d or --display: echoes TXT on the console as well"

espeak_tool="$(which espeak 2>/dev/null)"

if [ ! -x "${espeak_tool}" ]; then

	echo "  Error, no espeak tool available." 1>&2

	exit 5

fi

if [ "$1" = "-d" ] || [ "$1" = "--display" ]; then

	shift
	echo "$*"

fi

# As a last-resort option, tries to make a sound (any):
if ! "${espeak_tool}" "$*" 1>/dev/null 2>&1; then

	echo "(TTS error detected)" 1>&2
	exit 10

fi
