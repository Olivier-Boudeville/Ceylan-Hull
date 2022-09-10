#!/bin/sh

usage="Usage: $(basename $0) [--announce|-a] [--quiet|-q] [--shuffle|-s] [--recursive|-r] [file_or_directory1 file_or_directory2 ...]

 Performs an audio-only playback of the specified content files (including video ones) and directories, possibly with the following options:
  --announce or -a: announces the filename that will be played immediately (with vocal synthesis)
  --quiet or -q: does no perform console output
  --shuffle or -s: plays the specified elements in a random order
  --recursive or -r: selects content files automatically and recursively, from the current directory

(default: no announce, not quiet, no shuffle, not recursive - unless no files nor directories are specified)

  Notes:
   - the underlying audio player remains responsive (to console-level interaction, for example to pause it)
   - for smaller size and processing effort, video content may be replaced by pure audio one, thanks to our extract-audio-from-video.sh script
"

# Hidden options:
#  - useful for recursive uses: "--no-notification"
#  - just displays usage notification and exits: "--just-notification"

espeak="$(which espeak 2>/dev/null)"
notify_cmd="$(which notify-send 2>/dev/null)"

#echo "$(basename $0) parameters: $*"


say()
{

	#echo "$*"
	${espeak} --punct="" "$*" 2>/dev/null

}


display_notification()
{

	if [ "${player_name}" = "mplayer" ]; then

		# Duplicated in listen-to-radio.sh:
		echo " Using mplayer, hence one may hit:"
		echo "  - <space> to pause/unpause the current playback"
		echo "  - '/' to decrease the volume, '*' to increase it"
		# Useless: 'Enter' does it better: echo "  - 'U' at any moment to stop the current playback and jump to any next one"
		echo "  - left and right arrow keys to go backward/forward in the current playback"
		echo "  - <Enter> or <Escape> to jump to next playback"
		echo "  - <CTRL-C> to stop all playbacks"
		echo

	fi

}

# To display playback notifications:
do_display=1

if [ -x "${notify_cmd}" ]; then
	do_display=0
fi

player_name="mplayer"

player="$(which "${player_name}" 2>/dev/null)"

# For mplayer:
player_opt="-vc null -vo null -quiet"


# VLC also relevant:
#player=$(which cvlc 2>/dev/null)
#player_opt="--quiet --novideo --play-and-exit"


if [ ! -x "${player}" ]; then

	echo "Error, no executable player found (${player})." 1>&2
	exit 5

fi

# Could be used with mplayer:
#mplayer_cmd="${player} -msglevel identify=6 $f | grep -e '^ID_' | grep -v ID_AUDIO_ID | grep -v ID_DEMUXER | grep -v ID_FILENAME | grep -v ALSA"


do_announce=1
be_quiet=1
do_shuffle=1
be_recursive=1
display_notification=0


while [ ! $# -eq 0 ]; do

	token_eaten=1

	#echo "(examining $1)"

	if [ "$1" = "--announce" ] || [ "$1" = "-a" ]; then

		shift
		token_eaten=0

		if [ ! -x "${espeak}" ]; then

			echo "Error, espeak not found." 1>&2
			exit 15

		fi

		do_announce=0

	fi


	if [ "$1" = "--quiet" ] || [ "$1" = "-q" ]; then
		shift
		token_eaten=0
		be_quiet=0
	fi

	if [ "$1" = "--shuffle" ] || [  "$1" = "-s" ]; then
		shift
		token_eaten=0
		do_shuffle=0
	fi

	if [ "$1" = "--recursive" ] || [  "$1" = "-r" ]; then
		shift
		token_eaten=0
		be_recursive=0
	fi


	if [ "$1" = "--no-notification" ]; then
		shift
		token_eaten=0
		display_notification=1
	fi

	if [ "$1" = "--just-notification" ]; then
		shift
		token_eaten=0
		display_notification
		exit 0
	fi

	if [ "$1" = "--help" ] || [ "$1" = "-h" ]; then

		shift
		token_eaten=0

		echo "${usage}"
		exit 0

	fi


	if [ $token_eaten -eq 1 ]; then

		#echo "Adding $1"
		files="${files} $1"
		shift

	fi

done


#echo "do_announce=${do_announce}"
#echo "be_quiet=${be_quiet}"
#echo "be_recursive=${be_recursive}"
#echo "display_notification=${display_notification}"

if [ $display_notification -eq 0 ]; then
	display_notification
fi

#echo "files=${files}"

# Not recursive yet, but may become:
if [ ${be_recursive} -eq 1 ]; then
	for e in ${files}; do

		if [ -d "${e}" ]; then
			echo " (as '${e}' is a directory, switching to recursive)"
			be_recursive=0
			break
			#else
			#   echo "${e} is not a directory"
		fi

	done
fi


if [ ${be_recursive} -eq 0 ] || [ -z "${files}" ]; then

	echo " (playing recursively from $(pwd))"

	# A sort is performed, as otherwise the 'find' order is pretty
	# meaningless/arbitrary (ex: 'PREFIX-11.ogg' would be selected before
	# 'PREFIX-7.ogg'), whereas quite often songs of an album have a common
	# prefix then their number in the series than a suffix (ex:
	# My_GROUP-MY_ALBUM-07-Mantract.mp3)

	files="${files} $(find . -iname '*.wav' -o -iname '*.ogg' -o -iname '*.mp3' -o -iname '*.mp4' -o -iname '*.avi' | sort 2>/dev/null)"

fi


#echo "files=${files}"

if [ $do_shuffle -eq 0 ]; then

	ordered_files="$(echo ${files} | tr ' ' '\n' | shuf -)"
	#echo "Shuffled files = ${ordered_files}"

else

	ordered_files="${files}"

fi


for f in ${ordered_files}; do

	# If a directory is specified, just recurse and play everything found:
	if [ -d "${f}" ]; then

		cd "${f}" && $0 --no-notification

	elif echo "${f}" | grep -q ".*\.m3u" ; then

		echo "(going through playlist in '${f}')"

		# Stripping comment-based annotations such as #EXTM3U or #EXTINF:
		"$0" --no-notification $(/bin/cat "${f}" | grep -v '^#')

	else

		if [ ! -f "${f}" ]; then

			echo "  (file ${f} not found, thus skipped)" 1>&2

		else

			[ $be_quiet -eq 0 ] || echo " - playing now ${f}"

			if [ $do_announce -eq 0 ]; then

				say_name="$(basename ${f} | sed 's|\..*$||1')"
				#echo "say_name = ${say_name}"

				say "Playing " "${say_name}"

			fi

			if [ $do_display -eq 0 ]; then

				album_name="$(basename $(dirname $(realpath ${f})) | sed 's|-| |g')"

				song_name="$(basename ${f} | sed 's|\..*$||1' | sed 's|\.| |g' | sed 's|-| |g')"

				${notify_cmd} "Playing now, from ${album_name}:" "${song_name}"  --icon=audio-x-generic

			fi

			# Useful to stop the overall reading as a whole:
			if ! ${player} ${player_opt} "${f}" 1>/dev/null 2>&1; then

				echo "Playback of ${f} failed, stopping." 1>&2
				exit 20

			fi

		fi

	fi

done


# Allows to avoid having several of these lines accumulate:
if [ $display_notification -eq 0 ]; then

	echo " (end of playback)"

fi
