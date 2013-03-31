#!/bin/sh

# -f: full information.

# Select relevant version control client:

if [ -d 'CVS' ] ; then
	cvs update -d $* 2>&1 | grep -v Updating
elif [ -d '.svn' ] ; then
   
	if [ "$1" = "-f" ]; then
		shift
		svn status $* -v
	else
		svn status $* 
	fi

else

	# -s / --short can be passed directly:
	git status $*
		
fi

