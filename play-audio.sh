#!/bin/sh


keep_vol_opt="--keep-volume"

# Default percentage of maximum volume:
target_volume=30
#target_volume=70

# To set a custom target volume:
settings_file="${HOME}/.ceylan-settings.etf"

# In the settings:
volume_key="audio_volume"

usage="Usage: $(basename $0) [--announce|-a] [--quiet|-q] [--shuffle|-s] [--recursive|-r] [${keep_vol_opt}] [file_or_directory1 file_or_directory2 ...]

 Performs an audio-only playback of the specified content files (including video ones) and directories, possibly with the following options:
  --announce or -a: announces the filename that will be played immediately (with vocal synthesis)
  --quiet or -q: does no perform console output
  --shuffle or -s: plays the specified elements in a random order
  --recursive or -r: selects content files automatically and recursively, from the current directory
  ${keep_vol_opt}: does not set a default volume
(default: no announce, not quiet, no shuffle, not recursive, detected audio output to, unless specified in a '${settings_file}', ${target_volume}% of the maximum volume - unless no files nor directories are specified)

  Notes:
   - the underlying audio player remains responsive (to console-level interaction, for example to pause it)
   - for smaller size and processing effort, video content may be replaced by pure audio one, thanks to our extract-audio-from-video.sh script
   - the host-specific default volume can be defined in the '${settings_file}' file, thanks to its '${volume_key}' key; for example: a '{ ${volume_key}, 35 }.' line ther will set the volume to 35% of its maximum value; otherwise the default volume (${target_volume}%) will apply
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

	# Note that this relates to the *base* player, that may be overridden
	# depending on the audio formats being played.

	# Duplicated in listen-to-radio.sh:

	if [ "${player_name}" = "mplayer" ]; then

		echo " Using mplayer for player now, hence one may hit:"
		echo "  - <space> to pause/unpause the current playback"
		echo "  - '/' to decrease the volume, '*' to increase it"
		# Useless: 'Enter' does it better: echo "  - 'U' at any moment to stop the current playback and jump to any next one"
		echo "  - left and right arrow keys to go backward/forward in the current playback"
		echo "  - <Enter> or <Escape> to jump to next playback"
		echo "  - <CTRL-C> to stop all playbacks"
		echo

	fi


	if [ "${player_name}" = "mpv" ]; then

		echo " Using mpv for player now, hence one may hit:"
		echo "  - <space> to pause/unpause the current playback"
		echo "  - '/' to decrease the volume, '*' to increase it"
		# Useless: 'Enter' does it better: echo "  - 'U' at any moment to stop the current playback and jump to any next one"
		echo "  - left and right arrow keys to go backward/forward in the current playback"
		echo "  - <Enter> or <Escape> to jump to next playback"
		echo "  - <CTRL-C> to stop all playbacks"
		echo

	fi


	# Apparently no solution to do the same with VLC:
	if [ "${player_name}" = "cvlc" ]; then

		echo " Using cvlc (VLC) for player now, hence one may hit:"
		echo "  - <CTRL-C> to stop the current playback"
		#echo "  - <CTRL-C> twice quickly to stop all playbacks"
		echo "  - <CTRL-Z> to stop all playbacks (and possibly 'kill %1' / 'jobs' afterwards)"
		echo

	fi


	if [ "${player_name}" = "ogg123" ]; then

	   echo " Using ogg123 for player now, hence one may hit CTRL-C once to go to the next playback, twice to stop all playbacks; use CTRL-Z to pause and fg to resume."
	   echo

	fi

}


# To display playback notifications:
do_display=1

if [ -x "${notify_cmd}" ]; then
	do_display=0
fi


# Not used anymore, as not able to read properly Ogg/Vorbis files (e.g. Ogg
# data, Vorbis audio, stereo, 44100 Hz, ~160000 bps):
#
mplayer_player_name="mplayer"
mplayer_player_opt="-vc null -vo null -quiet"


# Now preferred to mplayer:
mpv_player_name="mpv"

# As 'Option --vc was removed: use --vd=..., --hwdec=...':
#mpv_player_opt="-vc null -vo null -quiet"
mpv_player_opt="-vo null -quiet --msg-level=all=no"


# VLC also relevant:
vlc_player_name="cvlc"

vlc_player_opt="--quiet --novideo --play-and-exit"

# ogg123 useful too for Ogg-Vorbis files:

# Note that, to overcome the "ERROR: Cannot open device alsa." error,
# /etc/libao.conf might have to be updated, possibly to:
#
# """
# default_driver=pulse
# quiet
# """


ogg_player_name="ogg123"
ogg_player_opt="--quiet"


# Default, preferred for command-line control:
player_name="mpv"

player="$(which "${player_name}" 2>/dev/null)"


if [ ! -x "${player}" ]; then

	echo "Error, no executable player found ('${player}')." 1>&2
	exit 5

fi

if [ "${player_name}" = "mplayer" ]; then

	# For mplayer:
	player_opt="${mplayer_player_opt}"

elif [ "${player_name}" = "${mpv_player_name}" ]; then

	player_opt="${mpv_player_opt}"

elif [ "${player_name}" = "${vlc_player_name}" ]; then

	player_opt="${vlc_player_opt}"

elif [ "${player_name}" = "${ogg_player_name}" ]; then

	player_opt="${ogg_player_opt}"

fi


# Could be used with mplayer/mpv:
#mplayer_cmd="${player} -msglevel identify=6 $f | grep -e '^ID_' | grep -v ID_AUDIO_ID | grep -v ID_DEMUXER | grep -v ID_FILENAME | grep -v ALSA"


do_announce=1
be_quiet=1
do_shuffle=1
be_recursive=1
display_notification=0

# Setting the volume automatically allows to avoid accidentally-loud playbacks:
set_volume=0


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

	if [ "$1" = "${keep_vol_opt}" ]; then
		shift
		set_volume=1
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


# To test filenames with spaces:
#for f in ${files} | while read f ; do
#   echo "Listed '${f}'"
#done
#exit

#echo "do_announce=${do_announce}"
#echo "be_quiet=${be_quiet}"
#echo "be_recursive=${be_recursive}"
#echo "display_notification=${display_notification}"
#echo "set_volume=${set_volume}"


if [ "${set_volume}" -eq 1 ]; then

	echo "(not setting the volume)"

else

	# Possibly a symlink:
	if [ -e "${settings_file}" ]; then

		#echo "Reading the '${settings_file}' configuration file."

		config_volume="$(/bin/cat "${settings_file}" | grep -v '^[[:space:]]*%' | grep ${volume_key} | sed 's|.*, ||1' | sed 's| }.$||1')"

		if [ -n "${config_volume}" ]; then
			#echo "Read volume configured from '${settings_file}': ${config_volume}%".
			target_volume="${config_volume}"
		fi

	fi

	# Assuming PulseAudio:
	pacmd="$(which pacmd 2>/dev/null)"

	if [ ! -x "${pacmd}" ]; then

		echo " Error, no 'pacmd' tool found. Is PulseAudio used by this system?" 1>&2

		exit 50

	fi

	set_volume_script_name="set-audio-volume.sh"

	set_volume_script="$(which ${set_volume_script_name} 2>/dev/null)"

	if [ ! -x "${set_volume_script}" ]; then

		echo "  Error, our '${set_volume_script_name}' script could not be found." 1>&2

		exit 17

	fi

	if ! ${set_volume_script} ${target_sink} "${target_volume}"; then

		echo "  Error, failed to modify the volume for sink ${target_sink}." 1>&2

		exit 35

	fi

fi


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


base_player="${player}"
base_player_opt="${player_opt}"

# Records whether a player switch occurred:
#player_switch=1

# Never matching initially:
last_player="${base_player}"


for f in ${ordered_files}; do

	#echo "Processing '${f}'"

	# If a directory is specified, just recurse and play everything found:
	if [ -d "${f}" ]; then

		cd "${f}" && $0 --no-notification ; cd ..

	elif echo "${f}" | grep -q ".*\.m3u" ; then

		echo "(going through playlist in '${f}')"

		# Stripping comment-based annotations such as #EXTM3U or #EXTINF:
		"$0" --no-notification $(/bin/cat "${f}" | grep -v '^#')

	else

		if [ ! -f "${f}" ]; then

			echo "  (file '${f}' not found, thus skipped)" 1>&2

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

			# Will remain as long as my mplayer is unable to play Ogg-Vorbis
			# files:
			#
			#if echo "${f}" | grep -q ".*\.ogg"; then

				#echo "(activating Ogg workaround)"
				#player_switch=0
				#player_name="${ogg_player_name}"
				#player="${ogg_player_name}"
				#player_opt="${ogg_player_opt}"

			#fi

			# Will remain as long as my mplayer is unable to play at least some
			# IFF (little-endian) data, WAVE audio, Microsoft ADPCM WAV files
			# and Ogg/Vorbis ones:
			#
			#if echo "${f}" | grep -q ".*\.wav"; then
			# Should ogg123 be faulty as well:
			#if echo "${f}" | grep -q ".*\.wav\|.*\.ogg"; then

				#echo "(activating VLC workaround)"
				#player_switch=0
				#player_name="${vlc_player_name}"
				#player="${vlc_player_name}"
				#player_opt="${vlc_player_opt}"

			#fi

			if [ ! "${last_player}" = "${player}" ]; then
				display_notification
			fi

			last_player="${player}"

			if [ "${player_name}" = "mpv" ]; then

				#echo "Executing ${player} ${player_opt} ${f}"
				if ! ${player} ${player_opt} "${f}"; then

					exit 5

				fi

				# Finer control not needed:
				#res=$?
				#echo "res = ${res}"

			else

				# Useful to stop the overall reading as a whole:

				# Uncomment to diagnose any issue:
				#if ! ${player} ${player_opt} "${f}"; then

				if ! ${player} ${player_opt} "${f}" 1>/dev/null 2>&1; then

					echo "Playback of ${f} failed, stopping." 1>&2
					exit 20

				fi

			fi

			# Restore defaults for next readings:
			#if [ $player_switch -eq 0 ]; then
			#
			#   player_switch=1
			#
			#   player="${base_player}"
			#   player_opt="${base_player_opt}"
			#
			#fi

		fi

	fi

done



# Allows to avoid having several of these lines accumulate:
if [ $display_notification -eq 0 ]; then

	echo " (end of playback)"

fi
