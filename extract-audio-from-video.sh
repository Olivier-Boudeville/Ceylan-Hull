#!/bin/sh

usage="Usage: $(basename $0) [-h|--help] VIDEO_FILE: strips the video information from specified file (in the MP4 or 3GP format) to generate a pure audio file (.ogg) out of it (the original video file is not modified).
 Relying on an audio file is useful, as: smaller, less resource-demanding to playback, and no video output gets in the way."

# About 3GP: https://en.wikipedia.org/wiki/3GP_and_3G2
# Insight: when possible, prefer MP4 to 3GP (which is for mobile 3G phones).

# Same content being playback, knowing the actual CPU time used by a process is
# user+sys:
#
# mp4: real 188,214 user 124,142    sys 63,560  pcpu 99,73
# ogg: real 188,258 user 1,340      sys 0,686   pcpu 1,07
#
# 124+63 = 187 vs 2, so ~93 times more demanding as mp4, and thus such
# extraction is worthwhile.

if [ "$1" = "-h" ] || [ "$1" = "--help" ]; then

	echo "${usage}"

	exit 0

fi


encoder_name="ffmpeg"

encoder="$(which ${encoder_name} 2>/dev/null)"

if [ ! -x "${encoder}" ]; then

	echo "  Error, encoder '${encoder_name}' not found." 1>&2

	exit 5

fi


video_file="$1"

if [ -z "${video_file}" ]; then

	echo "  Error, no file specified.
${usage}" 1>&2

	exit 5

fi


if [ ! -f "${video_file}" ]; then

	echo "  Error, input video file '${video_file}' not found." 1>&2

	exit 10

fi

# -r: extended regular expressions, meaning metacharacters do not have to be
# -escaped:
#
audio_file="$(echo "${video_file}" | sed -r 's|\.mp4\|\.3gp|.ogg|1')"


echo " Generating from video file '${video_file}' following audio one: '${audio_file}'..."

# -vn: disable video recording
# -acodec: set thes audio codec
# -y: overwrite output files without asking
# -aq: set the audio quality
#  * see http://wiki.hydrogenaud.io/index.php?title=Recommended_Ogg_Vorbis#Recommended_Encoder_Settings
#  * 5 results in ~160 kbps (insufficient in some cases, found surprisingly
# noisy), whereas 6 results in ~192 kbps (apparently perfect)
#
# -nostdin: explicitly disable console interactions

#quality=5

# Better:
quality=6

if ${encoder} -i "${video_file}" -vn -acodec libvorbis -aq ${quality} -nostdin -y -loglevel warning "${audio_file}"; then

	echo
	echo "  Generation of '${audio_file}' is successful."

else

	echo
	echo "  Generation of '${audio_file}' failed!" 1>&2

	exit 15

fi
