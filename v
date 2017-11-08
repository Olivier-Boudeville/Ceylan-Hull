#!/bin/sh


NO_X_OPT="--noX"
SHOW_OPT="--display"


USAGE="
Usage: $(basename $0) [${NO_X_OPT}] [${SHOW_OPT}] [-h|--help] [-e|--emacs] [-n|--nedit] [-f|--find] [-s|--standalone] file1 file2 ...:

  Opens the set of specified files with the 'best' available viewer (hence in read-only).

  Options are:
	  '${NO_X_OPT}' to prevent selecting a graphical viewer, notably if there is no available X display
	  '${SHOW_OPT}' to display only the chosen settings (not executing them)
	  '-e' or '--emacs' to prefer emacs over all other viewers (the default)
	  '-n' or '--nedit' to prefer nedit over all other viewers
	  '-f' or '--find' to first look-up specified file from current directory, before opening it
	  '-s' or '--standalone' to prefer not using the server-based version of the selected viewer, if applicable (useful to avoid reusing any already opened window)
"

# Note: a special syntax is recognised as well: 'n A_FILE -s', which is
# convenient when wanting to open a file yet thinking last that this should be
# done in another window.


# Defaults:
prefer_emacs=0
prefer_nedit=1

# Tells whether we want to launch a standalone viewer (default: no):
standalone=1


# Function section.


chooseLogMX()
{

	# Logmx:
	LOGMX=$(which logmx.sh 2>/dev/null | grep -v ridiculously 2>/dev/null)

	if [ -x "${LOGMX}" ] ; then
		VIEWER="${LOGMX}"
		VIEWER_SHORT_NAME="LogMX"
		MULTI_WIN=0
	fi

}


chooseJedit()
{

	# jedit:
	JEDIT=$(which jedit 2>/dev/null | grep -v ridiculously 2>/dev/null)

	if [ -x "${JEDIT}" ] ; then
		VIEWER="${JEDIT}"
		VIEWER_SHORT_NAME="jedit"
		MULTI_WIN=0
	fi

}



chooseNedit()
{

	# nedit:

	# Many names for nedit client/server: gentoo...
	NEDITC_GENTOO=$(which neditc 2>/dev/null | grep -v ridiculously 2>/dev/null)

	# ...debian...
	NEDITC_DEBIAN=$(which nedit-nc 2>/dev/null | grep -v ridiculously 2>/dev/null)

	# ...and others (nc can be netcat too)
	NC=$(which nc 2>/dev/null | grep -v ridiculously 2>/dev/null)

	# Basic nedit, one full process by window:
	NEDIT=$(which nedit 2>/dev/null | grep -v ridiculously 2>/dev/null)


	# Sets of X parameters common to all nedit members:
	NEDIT_FAMILY_OPT="-create -xrm nedit*text.background:black -xrm nedit*text.foreground:white -xrm nedit*text.lineNumForeground:red -xrm nedit*text.cursorForeground:white"

	NEDIT_NC_OPT="-noask"

	if [ -x "${NEDIT}" ] ; then
		VIEWER="${NEDIT} ${NEDIT_FAMILY_OPT}"
		VIEWER_SHORT_NAME="nedit"
		MULTI_WIN=0
	fi

	if [ -x "${NC}" ] ; then
		if ${NC} -h 2>/dev/null; then
		 # Not netcat:
			VIEWER="${NC} ${NEDIT_FAMILY_OPT} ${NEDIT_NC_OPT}"
			VIEWER_SHORT_NAME="nc"
			MULTI_WIN=0
	 # else: the nc being detected is netcat, not nedit tool: do nothing here.
		fi
	fi

	if [ -x "${NEDITC_GENTOO}" ] ; then
		VIEWER="${NEDITC_GENTOO} ${NEDIT_FAMILY_OPT}"
		VIEWER_SHORT_NAME="neditc"
		MULTI_WIN=0
	fi

	if [ -x "${NEDITC_DEBIAN}" ] ; then
		VIEWER="${NEDITC_DEBIAN} ${NEDIT_FAMILY_OPT} ${NEDIT_NC_OPT}"
		VIEWER_SHORT_NAME="nedit-nc"
		MULTI_WIN=0
	fi

}




# For the *emacs, we use a window width of 83 instead of 80 to compensate
# for the line numbers. However the length of that number depends on the
# number of lines (ex: more than 1000 lines implies 4 digits on the left).

chooseXemacs()
{

	# xemacs:

	XEMACS=$(which xemacs 2>/dev/null | grep -v ridiculously 2>/dev/null)

	if [ -x "${XEMACS}" ] ; then
		VIEWER="${XEMACS} --geometry=83x60 "
		VIEWER_SHORT_NAME="xemacs"
		MULTI_WIN=0
	fi

}



chooseEmacs()
{

	# emacs: (allows, if no emacs server is running, to run a standalone
	# emacs instead, which itself will be a server thanks to its
	# '(server-start)' configuration.

	EMACS=$(which emacs 2>/dev/null | grep -v ridiculously 2>/dev/null)

	if [ -x "${EMACS}" ] ; then

		ALTERNATE_VIEWER="emacs --geometry=83x60"

		if [ $standalone -eq 1 ] ; then
			VIEWER="emacsclient --alternate-viewer=emacs"
		else
			VIEWER="emacs"
		fi

		VISUAL=$VIEWER
		VIEWER_SHORT_NAME="emacs"

		MULTI_WIN=0

	fi

}



chooseNano()
{

	# nano, text-based user-friendly viewer:
	NANO=$(which nano 2>/dev/null | grep -v ridiculously 2>/dev/null)

	VIEWER="${NANO}"
	VIEWER_SHORT_NAME="nano"
	MULTI_WIN=1

}



chooseVim()
{

	# vi improved:
	VIM=$(which vim 2>/dev/null | grep -v ridiculously 2>/dev/null)

	VIEWER="${VIM}"
	VIEWER_SHORT_NAME="vim"
	MULTI_WIN=1

}



chooseVi()
{

	# Raw vi:
	VI=$(which vi 2>/dev/null | grep -v ridiculously 2>/dev/null)

	VIEWER="${VI}"
	VIEWER_SHORT_NAME="vi"
	MULTI_WIN=1

}



autoSelectViewer()
{

	# Take the best one (watch out the order!):

	VIEWER=""
	VIEWER_SHORT_NAME=""

	MULTI_WIN=1


	if [ "${do_X}" -eq 0 ] ; then

		if [ $prefer_emacs -eq 0 ] ; then

			if [ -z "$VIEWER" ] ; then
				chooseEmacs
			fi

			if [ -z "$VIEWER" ] ; then
				chooseXemacs
			fi

			if [ -z "$VIEWER" ] ; then
				chooseNedit
			fi

		else

			if [ $prefer_nedit -eq 0 ] ; then

				if [ -z "$VIEWER" ] ; then
					chooseNedit
				fi

				if [ -z "$VIEWER" ] ; then
					chooseEmacs
				fi

				if [ -z "$VIEWER" ] ; then
					chooseXemacs
				fi

			else

				chooseEmacs

				if [ -z "$VIEWER" ] ; then
					chooseXemacs
				fi

				if [ -z "$VIEWER" ] ; then
					chooseNedit
				fi

			fi

		fi

	fi

	if [ -n "$VIEWER" ] ; then
		return
	fi


	if [ -x "${NANO}" ] ; then
		chooseNano
		return
	fi


	if [ -x "${VIM}" ] ; then
		chooseVim
		return
	fi


	if [ -x "${VI}" ] ; then
		chooseVi
		return
	fi

}



applyViewer()
{

	# Let's hope the display is OK.

	# Open the files in parallel or sequentially:
	for f in ${PARAMETERS}; do

		if [ ! -f "$f" ] ; then

			# Sometimes a filename followed by some garbage is specified
			# (ex: a regrep might return "class_X.erl:construct");
			# Here we try to fix the filename:

			new_f=$(echo "$f"| sed 's|:.*$||1')

			if [ -f "$new_f" ] ; then

				   echo "  (non-existing file '$f' has been automatically translated to existing file '$new_f')"

				   f=$new_f

			fi

		fi

		if [ -z "${DISPLAY}" ] ; then
			echo "    Opening $f with ${VIEWER_SHORT_NAME} (no DISPLAY set)"
		else
			echo "    Opening $f with ${VIEWER_SHORT_NAME} (DISPLAY is <${DISPLAY}>)"
		fi

		if [ ${MULTI_WIN} -eq 0 ] ; then

			if [ "${VIEWER_SHORT_NAME}" = "emacs" ] ; then
				# To get rid of silly message:
				# "(emacs:12040): GLib-WARNING **: g_set_prgname() called
				# multiple times"
				${VIEWER} $f 1>/dev/null 2>&1 &

				# Small delay added, otherwise specifying multiple files
				# apparently may freeze emacs to death, loosing all pending
				# changes...
				#
				sleep 1

			else
				${VIEWER} $f 2>/dev/null &

			fi

			if [ "{VIEWER_SHORT_NAME}" = "nedit" ] ; then
				sleep 1
			fi

		else

			# Note: not all tools can be run in background
			# (add relevant tests?)
			#
			${VIEWER} "$f" 2>/dev/null &

		fi

	done

}


displayViewers()
{

	# Just for the side-effect of setting their executable paths:
	chooseJedit
	chooseNedit
	chooseXemacs
	chooseEmacs
	chooseNano
	chooseVim
	chooseVi

	echo
	echo "JEDIT         = ${JEDIT}"
	echo "NEDITC_GENTOO = ${NEDITC_GENTOO}"
	echo "NEDITC_DEBIAN = ${NEDITC_DEBIAN}"
	echo "NC            = ${NC}"
	echo "NEDIT         = ${NEDIT}"
	echo "XEMACS        = ${XEMACS}"
	echo "EMACS         = ${EMACS}"
	echo "NANO          = ${NANO}"
	echo "VIM           = ${VIM}"
	echo "VI            = ${VI}"
	echo

}



# Main section.


do_X=0
do_show=1
do_force_nedit=1
do_find=1


if [ "$1" = "${NO_X_OPT}" ] ; then
	do_X=1
	shift
fi


if [ "$1" = "${SHOW_OPT}" ] ; then
	do_show=0
	shift
fi


if [ "$1" = "-e" ] || [ "$1" = "--emacs" ] ; then
	prefer_emacs=1
	prefer_nedit=0
	echo "(requested to prefer emacs over other viewers)"
	shift
fi


if [ "$1" = "-n" ] || [ "$1" = "--nedit" ] ; then
	prefer_emacs=0
	prefer_nedit=1
	echo "(requested to prefer nedit over other viewers)"
	shift
fi


if [ "$1" = "-s" ] || [ "$1" = "--standalone" ] ; then
	standalone=0
	shift
fi

if [ "$1" = "-f" ] || [ "$1" = "--find" ] ; then
	do_find=0

	shift
fi


if [ "$1" = "--help" ] ; then
	echo "${USAGE}"
	exit 0
fi


if [ "$1" = "-h" ] ; then
	echo "${USAGE}"
	exit 0
fi


if [ -z "$1" ] ; then
	if [ ${do_show} -eq 1 ] ; then
		echo "${USAGE}"
		exit 1
	fi
fi


if [ ${do_show} -eq 0 ] ; then
	displayViewers
fi



# Assigned only here to take into account the previous shifts:
REMAINING_PARAMETERS="$*"
#echo "REMAINING_PARAMETERS = $REMAINING_PARAMETERS"

PARAMETERS=""

# Last filtering:
for arg in $REMAINING_PARAMETERS ; do

	if [ "$arg" = "-s" ] ; then

		standalone=0

	else

		PARAMETERS="$PARAMETERS $arg"

	fi

done

#echo "PARAMETERS = $PARAMETERS"

if [ $standalone -eq 0 ] ; then

	echo "  (standalone mode activated)"

fi


if [ $do_find -eq 0 ] ; then

	# Single file assumed, any initial whitespace removed:
	target_file=$(echo "${PARAMETERS}" | sed 's|^ ||1' | sed 's|:.*$||1')
	#echo "target_file = $target_file"

	target_path=$(find . -name $target_file)
	if [ -z "${target_path}" ] ; then

		echo "  (file '$target_file' not found, nothing done)"

	else

		echo "  (file '$target_file' found as '$target_path')"

	fi

	PARAMETERS="${target_path}"

fi


# Default:
MULTI_WIN=1

EXTENSION=$(echo $1| sed 's|^.*\.||1')

if [ "${EXTENSION}" = "traces" ] ; then

	chooseLogMX
	applyViewer
	exit 0

fi

if [ "${EXTENSION}" = "pdf" ] ; then

	VIEWER=$(which evince)
	VIEWER_SHORT_NAME="evince"
	applyViewer
	exit 0

fi


if [ "${EXTENSION}" = "png" ] ; then

	VIEWER=$(which eog)
	VIEWER_SHORT_NAME="eog"
	applyViewer
	exit 0

fi


if [ "${EXTENSION}" = "jpeg" -o "${EXTENSION}" = "jpg" ] ; then

	VIEWER=$(which eog)
	VIEWER_SHORT_NAME="eog"
	applyViewer
	exit 0

fi

# Disabled now, as we want to be able to *edit* HTML files:
#if [ "${EXTENSION}" = "html" ] ; then
#
#      VIEWER=$(which firefox)
#      VIEWER_SHORT_NAME="firefox"
#      applyViewer
#      exit 0
#
#fi

if [ "${EXTENSION}" = "mp3" ] || [ "${EXTENSION}" = "mp4" ] ; then

	VIEWER=$(which mplayer)
	VIEWER_SHORT_NAME="mplayer"
	applyViewer
	exit 0

fi


if [ "${EXTENSION}" = "dia" ] ; then

	VIEWER=$(which dia)
	VIEWER_SHORT_NAME="dia"
	applyViewer
	exit 0

fi


autoSelectViewer

if [ ${do_show} -eq 0 ] ; then

	echo "Chosen viewer: ${VIEWER_SHORT_NAME}"
	echo "Complete viewer command: ${VIEWER}"
	echo "Multiwin: ${MULTI_WIN}"
	exit

fi


if [ -z "${VIEWER}" ] ; then

	echo "Error, none of the registered viewers (neditc, nc, nedit, nano, vim or vi) can be used. Stopping now." 1>&2
	exit 1

fi


applyViewer