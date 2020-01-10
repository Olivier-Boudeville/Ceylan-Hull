#!/bin/sh

usage="  Usage: $(basename $0) [--announce|-a] [--quiet|-q] [--recursive|-r] [file1 file2 ...]

  Playbacks audio files as specified:
	  --announce: announce the filename that will be played immediatly (with espeak)
	  --quiet: not console output wanted
	  --recursive: (also) select audio files automatically and recursively, from the current directory
  (default: no announce, not quiet, not recursive - unless no files are specified)

  Note: the underlying audio player remains responsive (console-level interaction, for example to pause it).
"

# See also: just-listen-no-video.sh.


espeak=$(which espeak 2>/dev/null)


say()
{

	#echo "$*"
	${espeak} --punct="" "$*" 2>/dev/null

}


player=$(which mplayer 2>/dev/null)
player_opt="-novideo"

#player=$(which cvlc 2>/dev/null)
#player_opt="--novideo"


if [ ! -x "${player}" ] ; then

	echo "Error, no executable player found (${player})." 1>&2
	exit 5

fi

# Could be used with mplayer:
mplayer_cmd="${player} -msglevel identify=6 $f |grep -e '^ID_'|grep -v ID_AUDIO_ID |grep -v ID_DEMUXER |grep -v ID_FILENAME |grep -v ALSA"


do_announce=1
be_quiet=1
be_recursive=1


while [ ! $# -eq 0 ] ; do

	if [ "$1" = "--announce" -o "$1" = "-a" ] ; then

		shift

		if [ ! -x "${espeak}" ] ; then

			echo "Error, espeak not found." 1>&2
			exit 15

		fi

		do_announce=0

	fi


	if [ "$1" = "--quiet" -o "$1" = "-q" ] ; then
		shift
		be_quiet=0
	fi


	if [ "$1" = "--recursive" -o "$1" = "-r" ] ; then
		shift
		be_recursive=0
	fi

done


#echo "do_announce=${do_announce}"
#echo "be_quiet=${be_quiet}"
#echo "be_recursive=${be_recursive}"

files="$*"

if [ ${be_recursive} -eq 0 ] || [ -z "${files}" ]; then

	echo " (playing recursively from $(pwd))"

	files="${files} $(find . -iname '*.wav' -o -iname '*.ogg' -o -iname '*.mp3' 2>/dev/null)"

fi

#echo "files=${files}"


for f in ${files} ; do

	if [ ! -f "${f}" ] ; then

		echo "  (file ${f} not found, thus skipped)" 1>&2

	else

		[ $be_quiet -eq 0 ] || echo "  - playing now ${f}"

		if [ $do_announce -eq 0 ] ; then

			say_name=$(basename ${f}|sed 's|\..*$||1')
			#echo "say_name = ${say_name}"

			say "Playing " ${say_name}

		fi

		${player} ${player_opt} ${f} 1>/dev/null 2>&1

		# Useful to stop the overall reading as a whole:
		if [ ! $? -eq 0 ] ; then

			echo "Playback of ${f} failed, stopping." 1>&2
			exit 20

		fi

	fi

done

echo " (end of playback)"
