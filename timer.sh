#!/bin/bash

USAGE="Usage : "`basename $0`" <waiting time in minutes>. Will play bong when time is elapsed, useful for cooking."

if [ -z "$1" ] ; then
	echo "$USAGE"
	exit 1
fi

WAVE_PLAYER_ONE=`which playwave 2>/dev/null`
WAVE_PLAYER_TWO=`which wavplay 2>/dev/null`

if [ -x "${WAVE_PLAYER_ONE}" ]; then
	WAVE_PLAYER=${WAVE_PLAYER_ONE}
else
	WAVE_PLAYER=${WAVE_PLAYER_TWO}
fi
	
BONG_SOUND="${OSDL_ROOT}/../OSDL-data/gong.wav"
DINNER_SOUND="${OSDL_ROOT}/../OSDL-data/dinnerIsReady.wav"
BONG_COUNT=2


bong()
{
	${WAVE_PLAYER} ${BONG_SOUND} 1>/dev/null 2>&1
	echo "Bong ! "
}


dinnerIsReady()
{
	${WAVE_PLAYER} ${DINNER_SOUND} 1>/dev/null 2>&1
	echo "Dinner is ready !"

}

if [ ! -x "$WAVE_PLAYER" ] ; then
	echo "No executable wave player found." 
	exit 2
fi

if [ ! -f "$DINNER_SOUND" ] ; then
	
	echo "Dinner-is-ready sound file not found ($DINNER_SOUND)."
	exit 3
	
fi

if [ ! -f "$BONG_SOUND" ] ; then

	echo "Gong sound file not found ($BONG_SOUND)."
	exit 3
	
fi

bong

echo "Will wait for $1 minute(s) after this initial bong and will make noise when time is up...."
echo "(starting time : `date '+%H:%M:%S'`)"

let "waitingTime = $1 * 60"

#echo "Will wait for $waitingTime seconds"

sleep $waitingTime

echo ".... time is up, dinner's ready !!!!"
 
count=1

while [ "$count" -le "$BONG_COUNT" ] ; do
	bong
	sleep 1
    count=$(($count+1))
done
   
echo ".... time is up, dinner's ready !!!!"
dinnerIsReady

count=1

while [ "$count" -le "$BONG_COUNT" ] ; do
	bong
	sleep 1
    count=$(($count+1))
done
echo ".... time is up, dinner's ready !!!!"
   

