#!/bin/sh

usage="  Usage: $(basename $0) [--announce|-a] [--quiet|-q] [--recursive|-r] [file1/directory1 file/directory2 ...]

  Performs an audio-only playback of specified content files (including video ones) and directories:
	  --announce: announce the filename that will be played immediatly (with espeak)
	  --quiet: no console output wanted
	  --recursive: (also) select content files automatically and recursively, from the current directory
  (default: no announce, not quiet, not recursive - unless no files nor directories are specified)

  Note: the underlying audio player remains responsive (console-level interaction, for example to pause it).
"

# Hidden option, useful for recursive uses: "--no-notification"

espeak=$(which espeak 2>/dev/null)


say()
{

	#echo "$*"
	${espeak} --punct="" "$*" 2>/dev/null

}

player_name="mplayer"

player=$(which ${player_name} 2>/dev/null)

# In many cases this will not work, use '-vc null -vo null' instead:
#player_opt="-novideo -quiet"
player_opt="-vc null -vo null -quiet"


# cvlc does not seem as easy to control from the command-line:
#player=$(which cvlc 2>/dev/null)
#player_opt="--quiet --novideo"


if [ ! -x "${player}" ] ; then

	echo "Error, no executable player found (${player})." 1>&2
	exit 5

fi

# Could be used with mplayer:
#mplayer_cmd="${player} -msglevel identify=6 $f |grep -e '^ID_'|grep -v ID_AUDIO_ID |grep -v ID_DEMUXER |grep -v ID_FILENAME |grep -v ALSA"


do_announce=1
be_quiet=1
be_recursive=1
display_notification=0


while [ ! $# -eq 0 ] ; do

	token_eaten=1

	#echo "(examining $1)"

	if [ "$1" = "--announce" -o "$1" = "-a" ] ; then

		shift
		token_eaten=0

		if [ ! -x "${espeak}" ] ; then

			echo "Error, espeak not found." 1>&2
			exit 15

		fi

		do_announce=0

	fi


	if [ "$1" = "--quiet" -o "$1" = "-q" ] ; then
		shift
		token_eaten=0
		be_quiet=0
	fi


	if [ "$1" = "--recursive" -o "$1" = "-r" ] ; then
		shift
		token_eaten=0
		be_recursive=0
	fi


	if [ "$1" = "--no-notification" ] ; then
		shift
		token_eaten=0
		display_notification=1
	fi


	if [ "$1" = "--help" -o "$1" = "-h" ] ; then

		shift
		token_eaten=0

		echo "${usage}"
		exit 0

	fi


	if [ $token_eaten -eq 1 ] ; then

		#echo "Adding $1"
		files="${files} $1"
		shift

	fi

done


#echo "do_announce=${do_announce}"
#echo "be_quiet=${be_quiet}"
#echo "be_recursive=${be_recursive}"
#echo "display_notification=${display_notification}"

if [ $display_notification -eq 0 ] ; then

	if [ "${player_name}" = "mplayer" ] ; then

		echo " Using mplayer, hence one may hit:"
		echo "  - <space> to pause/unpause the current playback"
		echo "  - 'U' at any moment to stop the current playback and jump to any next one"
		echo "  - <CTRL-C> to stop all playbacks"
		echo "  - left and right arrow keys to go backward/forward in the current playback"
		echo

	fi

fi


if [ ${be_recursive} -eq 0 ] || [ -z "${files}" ]; then

	echo " (playing recursively from $(pwd))"

	files="${files} $(find . -iname '*.wav' -o -iname '*.ogg' -o -iname '*.mp3' -o -iname '*.mp4' -o -iname '*.avi' 2>/dev/null)"

fi

#echo "files=${files}"


for f in ${files} ; do

	# If a directory is specified, just recurse and play everything found:
	if [ -d "${f}" ] ; then

		cd "${f}" && $0 --no-notification

	elif echo "${f}" | grep -q ".*\.m3u" ; then

		echo "(going through playlist in '${f}')"

		# Stripping comment-based annotations such as #EXTM3U or #EXTINF:
		$0 --no-notification $(/bin/cat "${f}" | grep -v '^#')

	else

		if [ ! -f "${f}" ] ; then

			echo "  (file ${f} not found, thus skipped)" 1>&2

		else

			[ $be_quiet -eq 0 ] || echo " - playing now ${f}"

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

	fi

done


# Allows to avoid having several of these lines accumulate:
if [ $display_notification -eq 0 ] ; then

	echo " (end of playback)"

fi
