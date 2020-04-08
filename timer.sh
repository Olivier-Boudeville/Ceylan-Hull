#!/bin/sh

usage="Usage: $(basename $0) <waiting time in minutes>. Will play bong when time is elapsed, useful for cooking."

if [ -z "$1" ] ; then
	echo "$usage"
	exit 1
fi


first_audio_player=$(which playwave 2>/dev/null)
second_audio_player=$(which wavplay 2>/dev/null)
third_audio_player=$(which mplayer 2>/dev/null)

if [ -x "${first_audio_player}" ]; then
	audio_player=${first_audio_player}
else
	if [ -x "${second_audio_player}" ]; then
		audio_player=${second_audio_player}
	else
		if [ -x "${third_audio_player}" ]; then
			audio_player=${third_audio_player}
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
	${audio_player} ${bong_sound} 1>/dev/null 2>&1 &
	echo "Bong! "
}



dinnerIsReady()
{

	${audio_player} ${time_out_sound} 1>/dev/null 2>&1
	#echo "Dinner is ready!"
	echo "Time has come!"

}


if [ ! -x "$audio_player" ] ; then

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
echo "(starting time: "$(date '+%H:%M:%S')")"


waiting_time=$(($1 * 60))
echo "  Waiting for $waiting_time seconds now"

sleep $waiting_time

echo "(stopping time: "$(date '+%H:%M:%S')")"

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

# Would be too noisy:
#dinnerIsReady

echo ".... time is up!!!!"
