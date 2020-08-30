#!/bin/sh


usage="Usage: $(basename $0) MP4_FILE: strips the video information from specified MP4 file to generate a pure audio file (.ogg) out of it (original MP4 file not modified)."


# Same content being playback, knowing the actual CPU time used by a process is
# user+sys:
#
# mp4: real 188,214	user 124,142	sys 63,560	pcpu 99,73
# ogg: real 188,258	user 1,340		sys 0,686	pcpu 1,07
#
# 124+63 = 187 vs 2, so ~93 times more demanding as mp4, and thus such
# extraction is worthwhile.

encoder_name="ffmpeg"

encoder=$(which ${encoder_name} 2>/dev/null)

if [ ! -x "${encoder}" ]; then

	echo "  Error, encoder '${encoder_name}' not found." 1>&2

	exit 5

fi


video_file="$1"

if [ ! -f "${video_file}" ]; then

	echo "  Error, input file '${video_file}' not found." 1>&2

	exit 10

fi

audio_file=$(echo "${video_file}" | sed 's|\.mp4|.ogg|1')

echo " Generating from video file '${video_file}' following audio one: '${audio_file}'..."

# -vn: disable video recording
# -acodec: set thes audio codec
# -y: overwrite output files without asking.
# -aq: set the audio quality; http://wiki.hydrogenaud.io/index.php?title=Recommended_Ogg_Vorbis#Recommended_Encoder_Settings
#
${encoder} -i "${video_file}" -vn -acodec libvorbis -aq 5 -y -loglevel warning "${audio_file}"

if [ $? -eq 0 ]; then

	echo
	echo "Generation of '${audio_file}' successful."

else

	echo
	echo "Generation of '${audio_file}' failed!" 1>&2

	exit 10

fi
