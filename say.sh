#!/bin/sh

usage="Usage: ${basename} TEXT: says specified text, based on text to speech."

espeak_tool=$(which espeak)

if [ ! -x "${espeak_tool}" ]; then

	echo "  Error, no espeak tool available." 1>&2

	exit 5

fi

${espeak_tool} "$*" 1>/dev/null 2>&1

# As a last-resort option, tries to make a sound:
if [ ! $? -eq 0 ]; then

	bong.sh

fi
