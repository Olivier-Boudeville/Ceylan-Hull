#!/bin/sh

# Copyright (C) 2026-2026 Olivier Boudeville
#
# Author: Olivier Boudeville [olivier (dot) boudeville (at) esperide (dot) com]
#
# This file is part of the Ceylan-Hull toolbox (see http://hull.esperide.org).


# 2 minutes and 50 seconds:
duration_str="2:50"


usage="Usage: '$(basename $0) [-h|--help] [DURATION]: notifies that the tea is ready after the relevant duration, either the default one (${duration_str}) or a specified one, expressed as MINUTES (e.g. 3) or MINUTES:SECONDS (e.g. 2:45)

See also:
   - timer-in.sh for a more generic relative timer
   - timer-at.sh for a timer that is to trigger at an absolute timestamp (rather than after a duration from now)
   - timer-every.sh for a periodical timer"


if [ "$1" = "-h" ] || [ "$1" = "--help" ]; then
	echo "${usage}"
	exit
fi




if [ -n "$1" ]; then

	duration_str="$1"

fi


title="Tea is ready!"
message="${title} (${duration_str} elapsed)"


notify_script="$(which notify.sh 2>/dev/null)"


first_audio_player="$(which playwave 2>/dev/null)"
second_audio_player="$(which wavplay 2>/dev/null)"
third_audio_player="$(which mplayer 2>/dev/null)"
fourth_audio_player="$(which cvlc 2>/dev/null)"

audio_player_opts=""

if [ -x "${first_audio_player}" ]; then
	audio_player="${first_audio_player}"
elif [ -x "${second_audio_player}" ]; then
	audio_player="${second_audio_player}"
elif [ -x "${third_audio_player}" ]; then
	audio_player="${third_audio_player}"
elif [ -x "${fourth_audio_player}" ]; then
	audio_player="${fourth_audio_player}"
	audio_player_opts="--quiet --novideo --play-and-exit"
fi

# Can also be obtained from OpenOffice
# (/usr/lib/openoffice/share/gallery/sounds/gong.wav):
bong_sound="${LOANI_REPOSITORY}/OSDL-data/gong.wav"
#time_out_sound="${OSDL_ROOT}/../OSDL-data/dinnerIsReady.wav"

# Obtained with:
# record-speech.sh --voice-id 33 --speech-prefix "timer-end" --message 'The timer says: time is up!!!!'
time_out_sound="${LOANI_REPOSITORY}/OSDL-data/timer-end.wav"

# Otherwise a bit too noisy:
bong_count=0



bong()
{
	"${audio_player}" ${audio_player_opts} "${bong_sound}" 1>/dev/null 2>&1 &
	echo "Bong! "
}



time_has_come()
{

	"${audio_player}" ${audio_player_opts} "${time_out_sound}" 1>/dev/null 2>&1
	#echo "Dinner is ready!"
	#echo "Time has come!"

}


if [ ! -x "${notify_script}" ]; then

	echo "  Error, no executable notification script found." 1>&2
	exit 22

fi


if [ ! -x "${audio_player}" ]; then

	echo "  Error, no executable wave player found." 1>&2
	exit 23

fi


if [ ! -f "${bong_sound}" ]; then

	other_bong_sound="/usr/lib/libreoffice/share/gallery/sounds/beam.wav"

	if [ ! -f "${other_bong_sound}" ]; then

		echo "  Error, gong sound file not found (no '${bong_sound}' or '${other_bong_sound}')." 1>&2
		exit 24

	else

		bong_sound="${other_bong_sound}"

	fi

fi


if [ ! -f "${time_out_sound}" ]; then

	echo "Warning: time-out sound file not found ('${time_out_sound}'), using '${bong_sound}' instead." 1>&2
	time_out_sound="${bong_sound}"

fi


# In addition to 15:07:32, 15h07m32 is supported:
duration_str=$(echo ${duration_str} | tr 'h' ':' | tr 'm' ':')


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
${usage}" 1>&2
		exit 30

esac

#echo "duration_secs = ${duration_secs}"


# To ensure volume is sufficient and future notification can be heard:
bong 1>/dev/null

echo "  Will wait for a duration of ${user_duration} after this initial bong, and then will notify that the tea is ready..."


current_sec=$(date +%s)
stop_sec=$(expr ${current_sec} + ${duration_secs})
stop_time=$(date --date="@${stop_sec}" +%H:%M:%S)

echo "(start at $(date '+%H:%M:%S'), for an expected stop at ${stop_time}, i.e. after ${duration_secs} seconds)"

sleep ${duration_secs}

actual_stop_time="$(date '+%H:%M:%S')"

#echo ".... time is up! (1)"


count=1

while [ "${count}" -le "${bong_count}" ]; do

	bong
	sleep 1
	count=$((${count}+1))

done


#echo ".... time is up! (2)"
#time_has_come


count=1

while [ "${count}" -le "${bong_count}" ]; do

	bong
	sleep 1
	count=$((${count}+1))

done


# Would be too noisy:
#time_has_come

title="Tea is ready, stop the infusion immediately!"
message=""
#message="Tea is ready now, after ${user_duration}"
#message="Tea is ready, after ${user_duration}, at ${actual_stop_time}."


#echo "Notifying with title='${title}' and message='${message}'."


${notify_script} "${title}" "${message}" time

echo "(actual stopping time: ${actual_stop_time})"
