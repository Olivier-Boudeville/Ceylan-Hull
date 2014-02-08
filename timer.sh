#!/bin/sh

USAGE="Usage: "`basename $0`" <waiting time in minutes>. Will play bong when time is elapsed, useful for cooking."

if [ -z "$1" ] ; then
	echo "$USAGE"
	exit 1
fi


WAVE_PLAYER_ONE=`which playwave 2>/dev/null`
WAVE_PLAYER_TWO=`which wavplay 2>/dev/null`
WAVE_PLAYER_THREE=`which mplayer 2>/dev/null`

if [ -x "${WAVE_PLAYER_ONE}" ]; then
	WAVE_PLAYER=${WAVE_PLAYER_ONE}
else
	if [ -x "${WAVE_PLAYER_TWO}" ]; then
		WAVE_PLAYER=${WAVE_PLAYER_TWO}
	else
		if [ -x "${WAVE_PLAYER_THREE}" ]; then
			WAVE_PLAYER=${WAVE_PLAYER_THREE}
		fi
	fi
fi

# Can also be obtained from OpenOffice
# (/usr/lib/openoffice/share/gallery/sounds/gong.wav):
bong_sound="${LOANI_REPOSITORY}/OSDL-data/gong.wav"
#time_out_sound="${OSDL_ROOT}/../OSDL-data/dinnerIsReady.wav"

# Obtained with:
# record-speech.sh --voice-id 33 --speech-prefix "timer-end" --message 'The timer says: time is up!!!!'
time_out_sound="${LOANI_REPOSITORY}/OSDL-data/timer-end.wav"

bong_count=1



bong()
{
	${WAVE_PLAYER} ${bong_sound} 1>/dev/null 2>&1 &
	echo "Bong! "
}



dinnerIsReady()
{

	${WAVE_PLAYER} ${time_out_sound} 1>/dev/null 2>&1
	#echo "Dinner is ready!"
	echo "Time has come!"

}


if [ ! -x "$WAVE_PLAYER" ] ; then

	echo "  Error, no executable wave player found." 1>&2
	exit 2

fi

if [ ! -f "$time_out_sound" ] ; then

	echo "  Error, dinner-is-ready sound file not found ($time_out_sound)." 1>&2
	exit 3

fi


if [ ! -f "$bong_sound" ] ; then

	echo "  Error, gong sound file not found ($bong_sound)." 1>&2
	exit 4

fi


bong

echo "  Will wait for $1 minute(s) after this initial bong and will make noise when time is up...."
echo "(starting time: `date '+%H:%M:%S'`)"


waiting_time=$(($1 * 60))
echo "  Waiting for $waiting_time seconds now"

sleep $waiting_time

echo "(stopping time: `date '+%H:%M:%S'`)"

echo ".... time is up!"

count=1

while [ "$count" -le "$bong_count" ] ; do
	bong
	sleep 1
	count=$(($count+1))
done

echo ".... time is up!"
dinnerIsReady

count=1

while [ "$count" -le "$bong_count" ] ; do
	bong
	sleep 1
	count=$(($count+1))
done
dinnerIsReady
echo ".... time is up!!!!"
