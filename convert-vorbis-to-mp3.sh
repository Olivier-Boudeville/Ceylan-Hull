# Taken from:
# http://liquidat.wordpress.com/2007/12/03/short-tip-convert-ogg-file-to-mp3/

find -type f -name '*.ogg' | while read file; do echo "  + converting '$file'"; gst-launch-0.10 filesrc location="${file}" ! oggdemux ! vorbisdec ! audioconvert ! lame quality=4 ! id3v2mux ! filesink location=`echo "$file"|sed 's|.ogg$|.mp3|1'` 2>&1 && /bin/rm "$file"; done | tee -a convert-vorbis-to-mp3-results.txt
