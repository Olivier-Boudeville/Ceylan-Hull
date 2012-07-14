#!/bin/sh

current_dir="$( cd "$( dirname "$0" )" && pwd )"
converter="$current_dir/convert-vorbis-to-mp3.sh"

if [ ! -x "$converter" ] ; then

	echo "  Error, no executable converter found ('$converter')." 1>&2

	exit 15

fi

#echo "converter = $converter"

target_dir="$1"

if [ ! -d "$target_dir" ] ; then

	echo "  Error, target directory ('$target_dir') not found." 1>&2

	exit 20

fi

# Principle: you copy all the Ogg-Vorbis music you want into a target root tree,
# then you call this script of this directory: all Ogg files will be converted
# (with tags included) into MP3 files of good-enough quality.

# Note: erases the source ogg files.

cd $target_dir

find . -type f -name '*.ogg' -exec $converter '{}' ';'