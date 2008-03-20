#!/bin/sh

# -f: full.

# Select relevant version control client:

if [ -d 'CVS' ] ; then
	cvs update -d $*
else

	if [ "$1" = "-f" ]; then
		shift
		svn status $* -v
	else
		svn status $*
	fi	
		
fi

