#!/bin/sh

usage="Usage: '$(basename $0) [-h|--help] DURATION', i.e. requests to trigger a timer notification in DURATION, which is expressed as:
 MINUTES or MINUTES:SECONDS or HOURS:MINUTES:SECONDS
Will play bong when specified duration is elapsed; useful for example for cooking.
Ex: '$(basename $0) 15' will notify noisily once 15 minutes have elapsed.
See also: timer-at.sh for a timer that is to trigger at an absolute timestamp (rather than after a duration from now)."


if [ "$1" = "-h" ] || [ "$1" = "--help" ]; then
	echo "$usage"
	exit
fi


if [ -z "$1" ]; then
	echo "  Error, no target duration specified.
$usage"
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


if [ ! -x "$audio_player" ]; then

	echo "  Error, no executable wave player found." 1>&2
	exit 2

fi

if [ ! -f "$time_out_sound" ]; then

	echo "  Error, dinner-is-ready sound file not found ($time_out_sound)." 1>&2
	exit 3

fi


if [ ! -f "$bong_sound" ]; then

	echo "  Error, gong sound file not found ($bong_sound)." 1>&2
	exit 4

fi


if [ "$1" = "-h" ] || [ "$1" = "--help" ]; then
	echo "$usage"
	exit
fi

duration_str="$1"

if [ -z "${duration_str}" ]; then

	echo "  Error, no duration specified.
$usage" 1>&2
	exit 10

fi


# Let's count the colons to discriminate between MINUTES (0) / MINUTES:SECONDS
# (1) / HOURS:MINUTES:SECONDS (2):
#
colon_count=$(echo "${duration_str}" | awk -F":" '{print NF-1}')
#echo "colon_count = ${colon_count}"

# Determining duration_secs:
case ${colon_count} in

	0)
		#echo "Format MINUTES detected"
		minutes=${duration_str}
		duration_secs=$(expr ${minutes} \* 60)
		user_duration="${minutes} minutes"
		;;

	1)
		#echo "Format MINUTES:SECONDS detected"
		minutes=$(echo "${duration_str}" | awk -F":" '{print $1}')
		#echo "minutes = ${minutes}"
		secs=$(echo "${duration_str}" | awk -F":" '{print $2}')
		#echo "seconds = ${seconds}"
		minutes_as_secs=$(expr ${minutes} \* 60)
		duration_secs=$(expr ${minutes_as_secs} + ${secs})
		user_duration="${minutes} minutes and ${secs} seconds"
		;;

	2)
		#echo "Format HOURS:MINUTES:SECONDS detected"
		hours=$(echo "${duration_str}" | awk -F":" '{print $1}')
		#echo "hours = ${hours}"
		minutes=$(echo "${duration_str}" | awk -F":" '{print $2}')
		#echo "minutes = ${minutes}"
		secs=$(echo "${duration_str}" | awk -F":" '{print $3}')
		#echo "seconds = ${seconds}"
		hours_as_minutes=$(expr ${hours} \* 60)
		all_minutes=$(expr ${hours_as_minutes} + ${minutes})
		minutes_as_secs=$(expr ${all_minutes} \* 60)
		duration_secs=$(expr ${minutes_as_secs} + ${secs})
		user_duration="${hours} hours, ${minutes} minutes and ${secs} seconds"
		;;

	*)
		echo "Error, invalid duration specified: '${duration_str}'.
$usage" 1>&2
		exit 30

esac

#echo "duration_secs = ${duration_secs}"


# To ensure volume is sufficient and future notification can be heard:
bong 1>/dev/null

echo "  Will wait for a duration of ${user_duration} after this initial bong, and will make noise when time is up...."
current_sec=$(date +%s)
stop_sec=$(expr ${current_sec} + ${duration_secs})
stop_time=$(date --date="@${stop_sec}" +%H:%M:%S)

echo "(start at $(date '+%H:%M:%S'), for an expected stop at ${stop_time}, i.e. after ${duration_secs} seconds)"

sleep ${duration_secs}

actual_stop_time=$(date '+%H:%M:%S')

echo ".... time is up!"

count=1

while [ "$count" -le "$bong_count" ]; do
	bong
	sleep 1
	count=$(($count+1))
done

echo ".... time is up!"
dinnerIsReady

count=1

while [ "$count" -le "$bong_count" ]; do

	bong
	sleep 1
	count=$(($count+1))

done

# Would be too noisy:
#dinnerIsReady

echo ".... time is up!!!!"

echo "(actual stopping time: ${actual_stop_time})"
