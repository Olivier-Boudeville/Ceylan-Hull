#!/bin/sh

usage="Usage: $(basename $0) [-a|--autoplay] TARGET_VIDEO_URL: records, in a mp4 container file (*.mp4), the video of the web content (e.g. Youtube) designated by the specified target URL.

The -a / --autoplay options triggers an automatic playback (if possible with our 'v' script) of the resulting video file.

Note that any target URL that contains at least one character that is interpreted by the shell must be specified in a quoted manner.
For example: $(basename $0) \"https://www.youtube.com/watch?v=xxx&list=yyy&start_radio=1\".

See also our record-audio-from-url.sh script.
"


set -e

autoplay=1

if [ "$1" = "-a" ] || [ "$1" = "--autoplay" ]; then

	echo "(automatic playback enabled)"
	autoplay=0
	shift

fi


if [ ! $# -eq 1 ]; then

	echo "  Error, exactly one parameter expected.
${usage}" 1>&2

	exit 5

fi


# Wanting to get rid of suffixes like "&list=XXX&start_radio=1", which would
# lead to downloading unexpected, larger content (we just want to keep
# https://www.youtube.com/watch?v=XXX):
#
url="$(echo "$1" | sed 's|&.*||1')"
#echo "url=${url}"


# Refer to https://github.com/yt-dlp/yt-dlp:
downloader_exec="$(which yt-dlp 2>/dev/null)"

if [ ! -x "${downloader_exec}" ]; then

	echo "  Error, no 'yt-dlp' downloader available. On Arch, it can be obtained thanks to: 'pacman -S yt-dlp'." 1>&2

	exit 10

fi


ffmpeg_exec="$(which ffmpeg 2>/dev/null)"

if [ ! -x "${ffmpeg_exec}" ]; then

	echo "  Error, ffmpeg not available. On Arch, it can be obtained thanks to: 'pacman -S ffmpeg'." 1>&2

	exit 15

fi


fixer_exec="$(which fix-filename.sh 2>/dev/null)"

if [ ! -x "${fixer_exec}" ]; then

	echo "  Error, our Ceylan-Hull fix-filename.sh script is not available." 1>&2

	exit 20

fi


echo "  Downloading from '${url}'..."

# As Opus:

# Options of interest with yt-dlp are:
#  -q: quiet
#  (-s: "simulate" not used anymore)
#  (--no-warnings can be added)
#
# '+bestaudio[ext=m4a]/best[ext=mp4]' has been replaced by the more reliable
# '-f "bestvideo[ext=mp4]+bestaudio"'
#
#  --extractor-args "youtube:player_client=android" or
#    "youtube:player_client=web" may help
#
# (kept '%(artist)s' instead of '%(artist|uploader)s': if artist is not set, the
# resulting "NA-*" (for N/A) will be removed next; 'channel' exists also)

# --cookies-from-browser may allow to validate restrictions:
#ownload_extra_opts="--cookies-from-browser firefox"
download_extra_opts=""

mp4_path=$(${downloader_exec} -q --merge-output-format mp4 -f "bestvideo[ext=mp4]+bestaudio" ${download_extra_opts} --print after_move:filepath -o '%(artist)s-%(title)s.%(ext)s' "${url}")

res=$?

if [ ! ${res} -eq 0 ]; then

	echo "  Error, the fetching of '${url}' failed (exit code ${res})." 1>&2

	exit 25

fi

#echo "mp4_path: '${mp4_path}'."

mp4_file="$(basename "${mp4_path}")"

#echo "mp4_file: '${mp4_file}'."

if [ ! -f "${mp4_file}" ]; then

	echo "  Error, unable to find local fetched file '${mp4_file}'." 1>&2

	exit 30

fi


fixed_mp4_file="$(${fixer_exec} --porcelain --force "${mp4_file}")"

res=$?

#echo "fixed_mp4_file: '${fixed_mp4_file}'"

if [ ! ${res} -eq 0 ]; then

	echo "  Error, deriving the target filename from the original one ('${mp4_file}') failed (code: ${res}; obtained: '${fixed_mp4_file}')." 1>&2

	exit 35

fi


# Remove any leading "N/A" in artist not found, and any trailing useless suffix:
final_mp4_file="$(echo ${fixed_mp4_file} | sed -e 's|^NA-||' -e 's|-Official-Lyric-Video||' -e 's|-Lyrics-Video||' -e 's|-Lyric-Video||' -e 's|-Official-Video||' -e 's|-Original-Video||' -e 's|-Music-Video||' -e 's|-Exclusive-Video||' -e 's|-Official-Audio||' -e 's|-Official||' -e 's|-Audio-Officiel||')"

#echo "final_mp4_file: ${final_mp4_file}"

if [ -z "${final_mp4_file}" ]; then

	echo "  Error, empty final target mp4 filename." 1>&2

	exit 40

fi


#if "${ffmpeg_exec}" -loglevel error -i "${fixed_mp4_file}" -c:a copy "${final_mp4_file}"; then

if /bin/mv -f "${fixed_mp4_file}" "${final_mp4_file}"; then

   echo "Successfully generated '${final_mp4_file}'! (size: $(du -sh ${final_mp4_file} | awk '{printf $1}'))"

   #/bin/rm -f "${fixed_mp4_file}"

   if [ $autoplay -eq 0 ]; then

	   echo "  Auto-playing '${final_mp4_file}'..."

	   player="$(which v 2>/dev/null)"

	   if [ ! -x "${player}" ]; then

		   player="xdg-open"

	   fi

	   "${player}" "${final_mp4_file}"

   fi

else

   echo "Failed to generate '${final_mp4_file}' ('${fixed_mp4_file}' not removed)." 1>&2

   exit 100

fi
