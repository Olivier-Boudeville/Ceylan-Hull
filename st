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
	args="$*"

	git_opt="-c color.status=always"

	if [ -z "${args}" ] ; then

		# We find it more convenient to only start from the current directory,
		# rather than inspecting the full repository (hence the dot):
		#
		git ${git_opt} status .

	else

		git ${git_opt} status $*

	fi

fi
