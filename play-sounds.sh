#!/bin/sh

USAGE="  Usage: "`basename $0`" [ --announce | -a ] [ --quiet | -q] file1 file2 ...

  Playbacks specified audio files.
	  --announce: announce the filename that will be played immediatly (with espeak)
	  --quiet: not output wanted
"

espeak=`which espeak`

say()
{

	#echo "$*"
	${espeak} "$*"

}


#PLAYER=`which bplay`
PLAYER=`which mplayer`

# Could be used with mplayer:
MPLAYER_CMD="${PLAYER} -msglevel identify=6 $f |grep -e '^ID_'|grep -v ID_AUDIO_ID |grep -v ID_DEMUXER |grep -v ID_FILENAME |grep -v ALSA"

if [ ! -x "${PLAYER}" ] ; then

	echo "Error, no executable player found (${PLAYER})." 1>&2
	exit 5

fi


do_announce=1

if [ "$1" = "--announce" -o "$1" = "-a" ] ; then
	shift

	if [ ! -x "${espeak}" ] ; then

		echo "Error, espeak not found." 1>&2
		exit 15

	fi

	do_announce=0
fi



be_quiet=1

if [ "$1" = "--quiet" -o "$1" = "-q" ] ; then
	shift
	be_quiet=0
fi


for f in $* ; do

	if [ ! -f "${f}" ] ; then

		echo "  (file ${f} not found, thus skipped)" 1>&2

	else

		[ $be_quiet -eq 0 ] || echo "  Playing $f"

		if [ $do_announce -eq 0 ] ; then

			say "Playing ${f}"

		fi

		${PLAYER} ${f} 1>/dev/null 2>&1

	fi

done
