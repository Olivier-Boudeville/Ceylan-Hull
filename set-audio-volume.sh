#!/bin/sh

settings_file="${HOME}/.ceylan-settings.etf"

card_name_key="audio_card_name"

usage="Usage: $(basename $0) [-v] [[TARGET_AUDIO_SINK] NEW_PERCENTAGE_VOLUME]
  Sets the volume (as a percentage of the base maximum one - possibly going over 100%) of any specified audio sink, otherwise of any determined one, as read from any '${card_name_key}' entry in any '${settings_file}' configuration file, or, as a last resort, of an automatically detected one (currently first running sink, otherwise first idle one, otherwise first suspended one).

  Option: -v enables the verbose mode

  If executed with no argument, returns the current volume.
  For example, for the audio sink #30: $(basename $0) 30

  Especially useful when one's desktop widget (e.g. on a xfce4 panel) becomes sometimes totally unresponsive for unknown reasons, or to integrate in scripts (e.g. to listen to Internet radios with a controlled overall volume).

  Assumes that PulseAudio is used. Volume could be best set on a per-application basis, rather than globally.
"

# In this last case, 'pacmd list-sink-inputs' would be used, application.name or
# application.process.binary would be searched, the corresponding previous index
# obtained, and the 'pacmd set-sink-input-volume INDEX VOLUME' would be run.


# Otherwise just get the current volume:
do_set=0

is_verbose=1

if [ "$1" = "-v" ]; then

	shift
	is_verbose=0
	[ $is_verbose -eq 0 ] && echo "Verbose mode enabled."

fi



# Tries to reads the right sink to adjust, based on our configuration file.
#
# If found, the sink identifier is returned in the target_sink variable
# (corresponding to the numerical index of the audio sink of interest, like O,
# 199, etc.), otherwise "none" is returned.
#
read_audio_sink()
{

	# Assuming PulseAudio:
	pacmd="$(which pacmd 2>/dev/null)"

	if [ ! -x "${pacmd}" ]; then

		echo " Error, no 'pacmd' tool found. Is PulseAudio used by this system?" 1>&2

		exit 50

	fi

	# Initial value:
	target_sink="none"

	sink_type="configured"

	# Possibly a symlink:
	if [ ! -e "${settings_file}" ]; then

        echo "  No settings file ('${settings_file}') found, so no configured sink could be read."
        return

	fi

	target_card_name="$(/bin/cat "${settings_file}" | grep -v '^[[:space:]]*%' | grep ${card_name_key} | sed 's|.*,[[:space:]]*"||1' | sed 's|"[[:space:]]*}.$||1')"

	#echo "  Read, from '${settings_file}', the target card name: '${target_card_name}'."

	index="none"

	# Cannot use a loop as 'pacmd list-sinks | while read line; do', as no
	# variable (for any found sink) can be returned from it!
	#
	# Had to use a named pipe (see https://mywiki.wooledge.org/BashFAQ/024)

	# To avoid 'File exists':
	mkfifo my_pipe 2>/dev/null

	${pacmd} list-sinks > my_pipe &

	while IFS= read -r line; do

		if echo "${line}" | grep 'index:' 1>/dev/null; then
			#echo "index line = '${line}'"

			# Interested only in lines like '  index: 9' or '  * index: 199':
			index="$(echo "${line}" | awk -F: '{print $2}' | sed 's| ||g')"
			#echo "index = '${index}'"

			# Test is useless:
			#if [ -n "${index}" ]; then
			#  echo "Collected index '${index}'."
			#fi

		# For lines like '   alsa.card_name = "HDA Foobar"':
		elif echo "${line}" | grep 'alsa.card_name = "' 1>/dev/null; then

			#echo "card line = '${line}'"
			card_name="$(echo "${line}" | sed 's|^[[:space:]]*alsa.card_name = "||g' | sed 's|".*||g')"
			#echo "card_name = '${card_name}'"

			if [ "${card_name}" = "${target_card_name}" ]; then
				#echo "  Found sink index corresponding to this '${target_card_name}' card: '${index}'."
				target_sink="${index}"
				# No simple way to exit directly.

			fi

		fi

	done < my_pipe

	echo "  Read, from '${settings_file}', the target card name ('${target_card_name}'), which currently corresponds to sink #${target_sink}."

	/bin/rm my_pipe

}


# Tries to auto-detect the right sink to adjust, based on the state of the
# reported ones.
#
# The sink identifier is returned in the target_sink variable (corresponding to
# the numerical index of the audio sink of interest, like O, 199, etc.):
#
auto_determine_audio_sink()
{

	sink_type="auto-determined"

	# Number of context lines to return before the current state:
	line_context_count=4

	[ $is_verbose -eq 0 ] && echo "(checking running sinks)"
	sink_type="running"

	# Should multiple sinks match, we select the first one.
	#
	# NF is the number of fields of the current record, $NF is thus the value of
	# the last field:
	#
	target_sink="$(pacmd list-sinks | grep -B ${line_context_count} RUNNING | grep index | head -1 | awk ' { print $NF } ')"


	if [ -z "${target_sink}" ]; then

		[ $is_verbose -eq 0 ] && echo "(checking idle sinks)"
		sink_type="idle"
		target_sink="$(${pacmd} list-sinks | grep -B ${line_context_count} IDLE | grep index | head -1 | awk ' { print $NF } ')"

		if [ -z "${target_sink}" ]; then

			[ $is_verbose -eq 0 ] && echo "(checking suspended sinks)"
			sink_type="suspended"
			target_sink="$(${pacmd} list-sinks | grep -B ${line_context_count} SUSPENDED | grep index | head -1 | awk ' { print $NF } ')"

			if [ -z "${target_sink}" ]; then

				# We also could go for sink #0.

				echo "  Error: no running, idle or even suspended audio sink found." 1>&2

				exit 55

			else

				# Currently disabled, as apparently idle sinks may get
				# suspended:
				#
				#echo "  Warning: no running or idle audio sink found, using suspended one #${target_sink}." 1>&2
				:

			fi

		else

			echo "  Warning: no running audio sink found, using idle one #${target_sink}." 1>&2

		fi

	fi

	[ $is_verbose -eq 0 ] && echo "  Auto-detected sink: ${target_sink}."

}


detect_audio_sink()
{

	read_audio_sink

	#echo "After read, target_sink=${target_sink}."

	if [ "${target_sink}" = "none" ]; then
		auto_determine_audio_sink
	fi

}



if [ "$1" = "-h" ] || [ "$1" = "--help" ]; then

	echo "${usage}"

	exit

fi

if [ -n "$3" ]; then

	echo "  Error, extra argument specified.
${usage}" 1>&2

	exit 5

fi


# Sink and volume specified here:
if [ -n "$2" ]; then

	target_volume="$2"

    # So do_set=0

	sink_type="specified"
	target_sink="$1"

# Volume specified here, sink to be determined:
elif [ -n "$1" ]; then

	target_volume="$1"

	# So do_set=0

	# Having here to determine the relevant sink:

	detect_audio_sink

# Neither sink nor volume specified here:
else

	#echo "  Error, no target volume specified.
	#${usage}" 1>&2

	#exit 55

	do_set=1

	detect_audio_sink

fi


pactl="$(which pactl 2>/dev/null)"
if [ ! -x "${pactl}" ]; then

	echo " Error, no 'pactl' tool found. Is PulseAudio used by this system?" 1>&2

	exit 60

fi


# Always useful to report:
echo "  The current volume of the ${sink_type} audio sink #${target_sink} is:"

if ! "${pactl}" -- get-sink-volume "${target_sink}" | grep Volume; then

	echo "  Error, failed to read the volume for sink #${target_sink}." 1>&2

	exit 45

fi


if [ $do_set -eq 0 ]; then

	echo "  Setting volume to ${target_volume}% for ${sink_type} audio sink #${target_sink}."

	if ! "${pactl}" -- set-sink-volume "${target_sink}" "${target_volume}%"; then

		echo "  Error, failed to modify the volume for sink #${target_sink}." 1>&2

		exit 35

	fi

fi
