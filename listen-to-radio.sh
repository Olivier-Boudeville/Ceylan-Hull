#!/bin/sh

# Sources:
# - http://fluxradios.blogspot.com/
# - http://flux.radio.free.fr/

# Supposing that:
#  - 96kbps AAC is enough
#  - an Icecast version (https://en.wikipedia.org/wiki/Icecast) is better than a
#  "direct" one


play_stream()
{

	echo "  Playing ${current_stream_label}..."

	#echo "Wanting to run ${player} ${player_opt} ${current_stream_url}"
	#echo "Playing ${current_stream_url}"

	# Allows to display the group and song name, typically as sent by Radio
	# Paradise:
	#
	# (note that song names may contain single quotes, like in: "I'm All Right")

	# Use to debug:
	#if ! ${player} ${player_opt} "${current_stream_url}"; then

	# With mplayer:
	#if ! ${player} ${player_opt} "${current_stream_url}" 2>/dev/null | grep --line-buffered 'ICY Info:' | grep --line-buffered  -v 'Commercial-free - Listener-supported' | sed "s|^ICY Info: StreamTitle='|    -> |1; s|';StreamUrl=.*||1; s|';||1"; then

	#if ! ${player} ${player_opt} "${current_stream_url}" 2>/dev/null | grep --line-buffered 'ICY Info:' | grep --line-buffered  -v 'Commercial-free - Listener-supported' | sed "s|^ICY Info: StreamTitle='|    -> |1; s|';StreamUrl=.*||1"; then

	# With mpv:

	# (absolutely awful but needed to keep keyboard control in spite of keyboard
	# display, to be able to toggle between streams with the Enter key while
	# stopping for good with CTRL-C)

	#set -e
	set -o pipefail

	#if ! script --return --quiet -c "${player} --quiet --msg-level=all=no,display-tags=info --display-tags=icy-title ${current_stream_url}" /dev/null | grep --line-buffered -v 'File tags:' | grep --line-buffered -v 'Commercial-free - Listener-supported' | sed 's|icy-title:|    -> |1'; then

	script --return --quiet -c "${player} --quiet --msg-level=all=no,display-tags=info --display-tags=icy-title ${current_stream_url}" /dev/null | grep --line-buffered -v 'File tags:' | grep --line-buffered -v 'Commercial-free - Listener-supported' | sed 's|icy-title:|    -> |1'

	res="$?"

	#echo "res = ${res}"

	if [ "${res}" = "4" ]; then

		# We would like to simultaneously let the song name be echoed on the
		# terminal and be used as the text of a desktop notification, but we did
		# not manage (because of the line buffering?) to use a song name twice;
		# tried to add:
		#
		# | xargs -d $'\n' sh -c 'for arg do echo "A1$arg"; echo "A2$arg"; done' _ ; then

		# Nevertheless the following works as expected:
		# echo Foo | xargs -d $'\n' sh -c 'for arg do echo "A1$arg"; echo "A2$arg"; done' _

		echo "(stopping all playbacks)"
		exit 0

	fi

	set +o pipefail
	#set +e

}


base_codec="aac"

# Radio France:

#radio_france_code="${base_codec}"
radio_france_codec="mp3"


radio_france_base_url="icecast.radiofrance.fr"
#radio_france_base_url="direct"

france_culture_short_opt="-fc"
france_culture_long_opt="--france-culture"
france_culture_url="http://${radio_france_base_url}/franceculture-midfi.${radio_france_codec}"
france_culture_label="France Culture"

france_musique_short_opt="-fm"
france_musique_long_opt="--france-musique"
france_musique_url="http://${radio_france_base_url}/francemusique-midfi.${radio_france_codec}"
france_musique_label="France Musique"

france_info_short_opt="-fif"
france_info_long_opt="--france-info"
france_info_url="http://${radio_france_base_url}/franceinfo-midfi.${radio_france_codec}"
france_info_label="France Info"

france_inter_short_opt="-fit"
france_inter_long_opt="--france-inter"
france_inter_url="http://${radio_france_base_url}/franceinter-midfi.${radio_france_codec}"
#france_inter_url="http://direct.franceinter.fr/live/franceinter-midfi.${radio_france_codec}"
france_inter_label="France Inter"

fip_short_opt="-fi"
fip_long_opt="--fip"
fip_url="http://${radio_france_base_url}/fip-midfi.${radio_france_codec}"
fip_label="FIP"



# Radio Paradise:
# https://radioparadise.com/listen/stream-links

radio_paradise_main_short_opt="-rp"
radio_paradise_main_long_opt="--radio-paradise-main-mix"
radio_paradise_main_url="http://stream.radioparadise.com/aac-128"
radio_paradise_main_label="Radio Paradise Main Mix"

radio_paradise_mellow_short_opt="-rpm"
radio_paradise_mellow_long_opt="--radio-paradise-mellow-mix"
radio_paradise_mellow_url="http://stream.radioparadise.com/mellow-128"
radio_paradise_mellow_label="Radio Paradise Mellow Mix"

radio_paradise_rock_short_opt="-rpr"
radio_paradise_rock_long_opt="--radio-paradise-rock-mix"
radio_paradise_rock_url="http://stream.radioparadise.com/rock-128"
radio_paradise_rock_label="Radio Paradise Rock Mix"

radio_paradise_world_short_opt="-rpw"
radio_paradise_world_long_opt="--radio-paradise-world-mix"
radio_paradise_world_url="http://stream.radioparadise.com/world-etc-128"
radio_paradise_world_label="Radio Paradise World Mix"


oui_fm_short_opt="-of"
oui_fm_long_opt="--oui-fm"
oui_fm_url="http://ouifm.ice.infomaniak.ch/ouifm-high.aac"
oui_fm_label="Oui FM"

le_mouv_short_opt="-lm"
le_mouv_long_opt="--le-mouv"
le_mouv_url="http://direct.mouv.fr/live/mouv-midfi.mp3"
le_mouv_label="Le Mouv"

blp_short_opt="-blp"
blp_long_opt="--blp"

# blp_url="http://stream2.blpradio.fr:80/blpradio-HQ"
blp_url="http://stream2.blpradio.fr:80/blpradio"
blp_label="BLP Radio (la radio de la MJC Boby Lapointe de Villebon-sur-Yvette)"

default_url="${france_info_url}"
default_label="${france_info_label}"

fallback_url="${france_culture_url}"
fallback_label="${france_culture_label}"


keep_vol_opt="--keep-volume"

# Default percentage of maximum volume:
target_volume=30
#target_volume=70

# To set a custom target volume:
settings_file="${HOME}/.ceylan-settings.etf"

# In the settings:
volume_key="audio_volume"

usage="Usage: $(basename $0) [${keep_vol_opt}] [RADIO_OPT|STREAM_URL]: plays the specified Internet radio, where RADIO_OPT = SHORT_RADIO_OPT | LONG_RADIO_OPT may be, for:
  - Radio France:
	* ${france_culture_label}: ${france_culture_short_opt} | ${france_culture_long_opt}
	* ${france_musique_label}: ${france_musique_short_opt} | ${france_musique_long_opt}
	* ${france_info_label}: ${france_info_short_opt} | ${france_info_long_opt}
	* ${france_inter_label}: ${france_inter_short_opt} | ${france_inter_long_opt}
	* ${fip_label}: ${fip_short_opt} | ${fip_long_opt}
  - Radio Paradise:
	* ${radio_paradise_main_label}: ${radio_paradise_main_short_opt} | ${radio_paradise_main_long_opt}
	* ${radio_paradise_mellow_label}: ${radio_paradise_mellow_short_opt} | ${radio_paradise_mellow_long_opt}
	* ${radio_paradise_rock_label}: ${radio_paradise_rock_short_opt} | ${radio_paradise_rock_long_opt}
	* ${radio_paradise_world_label}: ${radio_paradise_world_short_opt} | ${radio_paradise_world_long_opt}
  - ${oui_fm_label}: ${oui_fm_short_opt} | ${oui_fm_long_opt}
  - ${le_mouv_label}: ${le_mouv_short_opt} | ${le_mouv_long_opt}
  - ${blp_label}: ${blp_short_opt} | ${blp_long_opt}

Outputs the audio streams of specified (online) radio, either preset or based on its specified stream URL.
By default, unless the '${keep_vol_opt}' option is specified, sets also the detected audio output: the host-specific default volume can be defined in the '${settings_file}' file, thanks to its '${volume_key}' key; for example: a '{ ${volume_key}, 35 }.' line there will set the volume to 35% of its maximum value; otherwise the default volume (${target_volume}%) will apply

  Note:
   - the underlying audio player remains responsive (to console-level interaction, for example to pause it)
   - if no radio is specified, will default to '${default_label}'
   - hit <Enter> or <Escape> to toggle between the selected stream and the fallback one (which is currently set to '${fallback_label}'); this is typically useful in order to escape from a starting series of advertisements or any similar uninteresting sequence
   - hit Ctrl-C to stop all playbacks
"

# Hidden option, useful for recursive uses: "--no-notification"


# This player choice and configuration shall be kept in line with the one of the
# play-audio.sh script.

#player_name="mplayer"
player_name="mpv"

player="$(which "${player_name}" 2>/dev/null)"

# For mplayer:
#player_opt="-vc null -vo null -quiet"
#player_opt="-nolirc -quiet -msglevel all=0:demuxer=4"

# For mpv:
# ~/.config/mpv/input.conf is expected to contain a
# 'ENTER playlist-next force' line.
#
player_opt="--quiet --msg-level=all=no,display-tags=info --display-tags=icy-title"

# VLC also relevant:
#player="$(which cvlc 2>/dev/null)"
#player_opt="--quiet --novideo --play-and-exit"


if [ ! -x "${player}" ]; then

	echo "Error, no executable player found (${player_name})." 1>&2
	exit 5

fi


# Setting the volume automatically allows to avoid accidentally-loud playbacks:
set_volume=0


if [ "$1" = "${keep_vol_opt}" ]; then
	shift
	set_volume=1
fi


display_notification=0



while [ ! $# -eq 0 ]; do

	token_eaten=1

	if [ "$1" = "${france_culture_short_opt}" ] || [ "$1" = "${france_culture_long_opt}" ]; then

		token_eaten=0

		stream_url="${france_culture_url}"
		stream_label="${france_culture_label}"

	fi

	if [ "$1" = "${france_musique_short_opt}" ] || [ "$1" = "${france_musique_long_opt}" ]; then

		token_eaten=0

		stream_url="${france_musique_url}"
		stream_label="${france_musique_label}"

	fi

	if [ "$1" = "${france_info_short_opt}" ] || [ "$1" = "${france_info_long_opt}" ]; then

		token_eaten=0

		stream_url="${france_info_url}"
		stream_label="${france_info_label}"

	fi


	if [ "$1" = "${france_inter_short_opt}" ] || [ "$1" = "${france_inter_long_opt}" ]; then

		token_eaten=0

		stream_url="${france_inter_url}"
		stream_label="${france_inter_label}"

	fi


	if [ "$1" = "${fip_short_opt}" ] || [ "$1" = "${fip_long_opt}" ]; then

		token_eaten=0

		stream_url="${fip_url}"
		stream_label="${fip_label}"

	fi


	if [ "$1" = "${radio_paradise_main_short_opt}" ] || [ "$1" = "${radio_paradise_main_long_opt}" ]; then

		token_eaten=0

		stream_url="${radio_paradise_main_url}"
		stream_label="${radio_paradise_main_label}"

	fi

	if [ "$1" = "${radio_paradise_mellow_short_opt}" ] || [ "$1" = "${radio_paradise_mellow_long_opt}" ]; then

		token_eaten=0

		stream_url="${radio_paradise_mellow_url}"
		stream_label="${radio_paradise_mellow_label}"

	fi

	if [ "$1" = "${radio_paradise_rock_short_opt}" ] || [ "$1" = "${radio_paradise_rock_long_opt}" ]; then

		token_eaten=0

		stream_url="${radio_paradise_rock_url}"
		stream_label="${radio_paradise_rock_label}"

	fi

	if [ "$1" = "${radio_paradise_world_short_opt}" ] || [ "$1" = "${radio_paradise_world_long_opt}" ]; then

		token_eaten=0

		stream_url="${radio_paradise_world_url}"
		stream_label="${radio_paradise_world_label}"

	fi

	if [ "$1" = "${oui_fm_short_opt}" ] || [ "$1" = "${oui_fm_long_opt}" ]; then

		token_eaten=0

		stream_url="${oui_fm_url}"
		stream_label="${oui_fm_label}"

	fi

	if [ "$1" = "${le_mouv_short_opt}" ] || [ "$1" = "${le_mouv_long_opt}" ]; then

		token_eaten=0

		stream_url="${le_mouv_url}"
		stream_label="${le_mouv_label}"

	fi

	if [ "$1" = "${blp_short_opt}" ] || [ "$1" = "${blp_long_opt}" ]; then

		token_eaten=0

		stream_url="${blp_url}"
		stream_label="${blp_label}"

	fi


	if [ "$1" = "--help" ] || [ "$1" = "-h" ]; then

		token_eaten=0

		echo "${usage}"
		exit 0

	fi


	if [ $token_eaten -eq 1 ]; then

		stream_url="$1"
		stream_label="unknown stream ${stream_url}"

	fi

	shift

	if [ ! $# -eq 0 ]; then

		echo "  Error, too many parameters specified.
${usage}" 1>&2

		exit 25

	fi

done



if [ -z "${stream_url}" ]; then

	#echo "  Error, no radio stream selected.
#${usage}" 1>&2

	#exit 15

	stream_url="${default_url}"
	stream_label="default ${default_label} stream"

fi


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


#echo "display_notification=${display_notification}"

if [ $display_notification -eq 0 ]; then

	if [ "${player_name}" = "mplayer" ]; then

		# Duplicated in play-audio.sh:
		echo " Using mplayer, hence one may hit:"
		echo "  - <space> to pause/unpause the current playback"
		echo "  - '/' to decrease the volume, '*' to increase it"
		# Useless: 'Enter' does it better: echo "  - 'U' at any moment to stop the current playback and jump to any next one"
		echo "  - left and right arrow keys to go backward/forward in the current playback"
		echo "  - <Enter> or <Escape> to toggle between this stream ('${stream_label}') and the fallback one ('${fallback_label}')"
		echo "  - <CTRL-C> to stop all playbacks"
		echo

	elif [ "${player_name}" = "mpv" ]; then

		echo " Using mpv for player now, hence one may hit:"
		echo "  - <space> to pause/unpause the current playback"
		echo "  - '/' to decrease the volume, '*' to increase it"
		# Useless: 'Enter' does it better: echo "  - 'U' at any moment to stop the current playback and jump to any next one"
		echo "  - left and right arrow keys to go backward/forward in the current playback"
		echo "  - <Enter> or <Escape> to jump to next playback"
		echo "  - <CTRL-C> to stop all playbacks"
		echo "(refer to https://mpv.io/manual/stable/#keyboard-control for more information)"
		echo

	# Apparently no solution to do the same with VLC:
	elif [ "${player_name}" = "cvlc" ]; then

		echo " Using cvlc (VLC), hence one may hit:"
		echo "  - <CTRL-C> to stop the current playback"
		echo "  - <CTRL-C> twice quickly to stop all playbacks"
		echo

	fi


	if [ "${player_name}" = "ogg123" ]; then

	   echo " Using ogg123, hence one may hit CTRL-C once to go to the next playback, twice to stop all playbacks; use CTRL-Z to pause and fg to resume."
	   echo

	fi

fi



do_stop=1

while [ $do_stop -eq 1 ]; do

	current_stream_url="${stream_url}"
	current_stream_label="${stream_label}"

	if play_stream; then

		current_stream_url="${fallback_url}"
		current_stream_label="as fallback ${fallback_label}"

		play_stream

	fi

done



# Allows to avoid having several of these lines accumulate:
if [ $display_notification -eq 0 ]; then

	echo " (end of playback)"

fi
