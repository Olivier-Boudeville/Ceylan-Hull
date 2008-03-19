#!/bin/sh

# -s: short.

# Select relevant version control client:

if [ -d 'CVS' ] ; then
	cvs update -d $*
else

	if [ $1 = "-s" ]; then
		shift
		svn status $*
	else
		svn status $* -v
	fi	
		
fi

