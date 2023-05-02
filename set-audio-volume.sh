#!/bin/sh


usage="Usage: $(basename $0) [[TARGET_AUDIO_SINK] NEW_PERCENTAGE_VOLUME]
  Sets the volume (as a percentage of the base maximum one - possibly going over 100%) either for the specified audio sink or for any automatically detected one (currently running sink, otherwise idle, otherwise suspended).

  If executed with no argument, returns the current volume.

  For example: $(basename $0) 30

  Especially useful when one's desktop widget (e.g. on a xfce4 panel) becomes sometimes totally unresponsive for unknown reasons.

  Assumes that PulseAudio is used.
"


# Otherwise just get the current volume:
do_set=0




# Returned in the target_sink variable:
detect_audio_sink()
{

	# Assuming PulseAudio:
	pacmd="$(which pacmd 2>/dev/null)"

	if [ ! -x "${pacmd}" ]; then

		echo " Error, no 'pacmd' tool found. Is PulseAudio used by this system?" 1>&2

		exit 50

	fi

	# Number of context lines to return before the current state:
	line_context_count=4

	#echo "(checking running sinks)"
	sink_type="running"
	target_sink="$(pacmd list-sinks | grep -B ${line_context_count} RUNNING | grep index | awk ' { print $NF } ')"


	if [ -z "${target_sink}" ]; then

		#echo "(checking idle sinks)"
		sink_type="idle"
		target_sink="$(${pacmd} list-sinks | grep -B ${line_context_count} IDLE | grep index | awk ' { print $NF } ')"

		if [ -z "${target_sink}" ]; then

			#echo "(checking suspended sinks)"
			sink_type="suspended"
			target_sink="$(${pacmd} list-sinks | grep -B ${line_context_count} SUSPENDED | grep index | awk ' { print $NF } ')"

			if [ -z "${target_sink}" ]; then

				# We also could go for sink #0.

				echo "  Error: no running, idle or even suspended audio sink found." 1>&2

				exit 55

			else

				echo "  Warning: no running or idle audio sink found, using suspended one #${target_sink}." 1>&2

			fi

		else

			echo "  Warning: no running audio sink found, using idle one #${target_sink}." 1>&2

		fi

	fi

	#echo "  Auto-detected sink: ${target_sink}."

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


if [ -n "$2" ]; then

	target_volume="$2"

	sink_type="specified"
	target_sink="$1"

elif [ -n "$1" ]; then

	target_volume="$1"

	# Having here to determine the relevant sink:
	detect_audio_sink

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

if ! "${pactl}" -- get-sink-volume ${target_sink} | grep Volume; then

	echo "  Error, failed to read the volume for sink #${target_sink}." 1>&2

	exit 45

fi


if [ $do_set -eq 0 ]; then

	echo "  Setting volume to ${target_volume}% for ${sink_type} audio sink #${target_sink}."

	if ! "${pactl}" -- set-sink-volume ${target_sink} "${target_volume}%"; then

		echo "  Error, failed to modify the volume for sink #${target_sink}." 1>&2

		exit 35

	fi

fi
