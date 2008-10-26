#!/bin/sh

USAGE="  Usage: "`basename $0`" [--quiet] file1 file2 ...

  Playbacks specified audio files.
      --quiet: not output wanted
"

#PLAYER=`which bplay`
PLAYER=`which mplayer`

if [ ! -x "${PLAYER}" ] ; then

	echo "Error, no executable player found (${PLAYER})." 1>&2
    exit 5
    
fi

be_quiet=1

if [ "$1" = "--quiet" ] ; then
	shift
	be_quiet=0
fi


for f in $* ; do

	if [ ! -f "${f}" ] ; then
    
    	echo "  (file ${f} not found, thus skipped)" 1>&2
        
    else
    
		[ $be_quiet -eq 0 ] || echo "  Playing $f"
        ${PLAYER} ${f} 1>/dev/null 2>&1
        
    fi
    
done
    
