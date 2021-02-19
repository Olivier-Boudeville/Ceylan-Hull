#!/bin/sh

usage="Usage: $(basename $0): converts specified MOV file to MP4."

# Inspired from:
# https://superuser.com/questions/525249/convert-avi-to-mp4-keeping-the-same-quality

# Note: leaves the source mov files.

file="$1"

if [ ! -f "$file" ]; then

	echo "  Error, '$file' is not an existing file." 1>&2

	exit 10

fi

target=$(echo ${file} | sed 's|.mov$|.mp4|1')

echo "  + converting '$file' into '$target'"

ffmpeg -y  -i ${file} -c:v libx264 -crf 19 -preset slow -c:a aac -b:a 192k -ac 2 ${target}

# If you want to avoid your computer to overheat too much:
sleep 4
