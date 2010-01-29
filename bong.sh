#!/bin/sh

USAGE="Usage: "`basename $0`". Makes a bong sound."



WAVE_PLAYER=`which playwave 2>//dev/null`
BONG_SOUND="${OSDL}/../../OSDL-data/gong.wav"
BONG_COUNT=5


bong()
{
	${WAVE_PLAYER} ${BONG_SOUND} 1>/dev/null 2>&1
	echo "Bong ! "
}


if [ ! -x "$WAVE_PLAYER" ] ; then
	echo "No executable wave player found." 
	exit 2
fi

if [ ! -f "$BONG_SOUND" ] ; then
	echo "Gong sound file not found ($BONG_SOUND)."
	exit 3
fi

bong
