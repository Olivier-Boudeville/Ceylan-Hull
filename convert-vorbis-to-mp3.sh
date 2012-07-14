# Inspired from:
# http://liquidat.wordpress.com/2007/12/03/short-tip-convert-ogg-file-to-mp3/


# Note: erases the source ogg files.

file=$1

if [ ! -f "$file" ] ; then

	echo "  Error, '$file' is not an existing file." 1>&2

	exit 10

fi


echo "  + converting '$file'"

# Quality seems ignored, but VBR not:

gst-launch-0.10 filesrc location="${file}" ! oggdemux ! vorbisdec ! audioconvert ! lame quality=2 vbr=new ! id3v2mux ! filesink location=`echo "$file"|sed 's|.ogg$|.mp3|1'` 1>/dev/null && /bin/rm -f "$file";


# If you want to avoid your computer to overheat too much:
sleep 1
