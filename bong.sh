#!/bin/sh

usage="Usage: $(basename $0) [COUNT]: plays COUNT (default: 1) bong sound(s). Useful for example to notify the end of a longer shell operation."


bong()
{
	echo ${audio_player_cmd} "${bong_sound}" #1>/dev/null 2>&1
	echo "Bong!"
}


audio_player=$(which cvlc 2>/dev/null)
audio_player_cmd="${audio_player} --quiet --novideo --play-and-exit"

bong_sound="${LOANI_REPOSITORY}/OSDL-data/gong.wav"

bong_count="$1"

if [ -z "${bong_count}" ]; then
	bong_count=1
fi


if [ ! -x "${audio_player}" ]; then
	audio_player=$(which mplayer 2>/dev/null)
	audio_player_cmd="${audio_player}"
fi


if [ ! -x "${audio_player}" ]; then
	echo "No executable audio player found."
	exit 2
fi

if [ ! -f "${bong_sound}" ]; then
	echo "Gong sound file not found (${bong_sound})."
	exit 3
fi


count=1

while [ ${count} -le ${bong_count} ]; do

	bong
	sleep 1
	count=$(($count+1))

done
