#!/bin/sh

usage="Usage: $(basename $0) [COUNT]: plays COUNT (default: 1) bong sound(s). Useful for example to notify the end of a longer shell operation."

use_sound=0


bong()
{
	if [ $use_sound -eq 0 ]; then

		${audio_player_cmd} "${bong_sound}" 1>/dev/null 2>&1

	else

		espeak "Bong!" 1>/dev/null 2>&1

	fi

	echo "Bong!"

}

bong_sound="${LOANI_REPOSITORY}/OSDL-data/gong.wav"

if [ ! -f "${bong_sound}" ]; then

	bong_sound="/usr/lib/libreoffice/share/gallery/sounds/beam.wav"

	if [ ! -f "${bong_sound}" ]; then

		espeak=$(which espeak 2>/dev/null)

		if [ -x "${espeak}" ]; then

			use_sound=1

		else

			echo "  Error, no suitable bong sound found, and no espeak available." 1>&2
			exit 15

		fi

	fi

fi


if [ $use_sound -eq 0 ]; then

	audio_player=$(which cvlc 2>/dev/null)
	audio_player_cmd="${audio_player} --quiet --novideo --play-and-exit"

	if [ ! -x "${audio_player}" ]; then
		audio_player=$(which mplayer 2>/dev/null)
		audio_player_cmd="${audio_player}"
	fi

	if [ ! -x "${audio_player}" ]; then
		echo "No executable audio player found."
		exit 2
	fi

fi


bong_count="$1"

if [ -z "${bong_count}" ]; then
	bong_count=1
fi


count=1

while [ ${count} -le ${bong_count} ]; do

	bong
	sleep 1
	count=$(($count+1))

done
