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

	#echo ${player} ${player_opt} "${current_stream_url}"

	# Allows to display the group and song name, typically as sent by Radio
	# Paradise:
	#
	# (note that song names may contain single quotes, like in: "I'm All Right")
	#
	if ! ${player} ${player_opt} "${current_stream_url}" 2>/dev/null | grep --line-buffered 'ICY Info:' | grep --line-buffered  -v 'Commercial-free - Listener-supported' | sed "s|^ICY Info: StreamTitle='|    -> |1; s|';StreamUrl=.*||1"; then

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


default_url="${france_info_url}"
default_label="${france_info_label}"

fallback_url="${france_culture_url}"
fallback_label="${france_culture_label}"


# [${}|${}]

usage="Usage: $(basename $0) [RADIO_OPT|STREAM_URL]: plays the specified Internet radio, where RADIO_OPT = SHORT_RADIO_OPT | LONG_RADIO_OPT may be:
  - for Radio France:
	* ${france_culture_short_opt} | ${france_culture_long_opt}
	* ${france_musique_short_opt} | ${france_musique_long_opt}
	* ${france_info_short_opt} | ${france_info_long_opt}
	* ${france_inter_short_opt} | ${france_inter_long_opt}
	* ${fip_short_opt} | ${fip_long_opt}
  - for Radio Paradise:
	* ${radio_paradise_main_short_opt} | ${radio_paradise_main_long_opt}
	* ${radio_paradise_mellow_short_opt} | ${radio_paradise_mellow_long_opt}
	* ${radio_paradise_rock_short_opt} | ${radio_paradise_rock_long_opt}
	* ${radio_paradise_world_short_opt} | ${radio_paradise_world_long_opt}
 - Oui FM: ${oui_fm_short_opt} | ${oui_fm_long_opt}
 - Le Mouv': ${le_mouv_short_opt} | ${le_mouv_long_opt}

Outputs the audio streams of specified (online) radio, either preset or based on its specified stream URL.

  Note:
   - the underlying audio player remains responsive (to console-level interaction, for example to pause it)
   - if no radio is specified, will default to '${default_label}'
   - hit <Enter> or <Escape> to toggle between the selected stream and the fallback one (which is currently set to '${fallback_label}'); this is typically useful in order to escape from a starting series of advertisements or any similar uninteresting sequence
   - hit Ctrl-C to stop all playbacks
"

# Hidden option, useful for recursive uses: "--no-notification"


player_name="mplayer"

player="$(which "${player_name}" 2>/dev/null)"

# For mplayer:
#player_opt="-vc null -vo null -quiet"
player_opt="-nolirc -quiet -msglevel all=0:demuxer=4"


# VLC also relevant:
#player=$(which cvlc 2>/dev/null)
#player_opt="--quiet --novideo --play-and-exit"


if [ ! -x "${player}" ]; then

	echo "Error, no executable player found (${player})." 1>&2
	exit 5

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
