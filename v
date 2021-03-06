#!/bin/sh


# Copyright (C) 2010-2021 Olivier Boudeville
#
# Author: Olivier Boudeville [olivier (dot) boudeville (at) esperide (dot) com]
#
# This file is part of the Ceylan-Hull toolbox.


# This script has for purpose to *view* (hence its name, 'v') files, so it opens
# them (as read-only) with a relevant tool.


# See also:
# - the 'e' ('edit') script
# - the 'xdg-open' command


no_x_opt="--noX"
show_opt="--display"


usage="
Usage: $(basename $0) [${no_x_opt}] [${show_opt}] [-h|--help] [-e|--emacs] [-n|--nedit] [-f|--find] [-s|--standalone] file1 file2 ...:

  Opens for reading the set of specified files (or directories) with the 'best' available viewer.

  Options are:
	  '${no_x_opt}' to prevent selecting a graphical viewer, notably if there is no available X display
	  '${show_opt}' to display only the chosen settings (not executing them)
	  '-e' or '--emacs' to prefer emacs over all other viewers (the default)
	  '-n' or '--nedit' to prefer nedit over all other viewers
	  '-f' or '--find' to first look-up specified file from current directory, before opening it
	  '-s' or '--standalone' to prefer not using the server-based version of the selected viewer, if applicable (useful to avoid reusing any already opened window)
	  '-l' or '--locate' to open the single file (if any) found thanks to 'locate'
"

# Note: a special syntax is recognised as well: 'n A_FILE -s', which is
# convenient when wanting to open a file yet thinking last that this should be
# done in another window.


viewer=""

# Not to be directly included in the viewer variable, so that it can be still
# tested with -x for example.
#
viewer_opt=""


# Defaults:
prefer_emacs=0
prefer_nedit=1

# Tells whether we want to launch a standalone viewer (default: no):
standalone=1

run_in_background=0



# Function section.


chooseJedit()
{

	#echo "Jedit selected."

	JEDIT="$(which jedit 2>/dev/null | grep -v ridiculously 2>/dev/null)"

	if [ -x "${JEDIT}" ]; then
		viewer="${JEDIT}"
		viewer_short_name="Jedit"
		multi_win=0
	fi

}


chooseEvince()
{

	#echo "Evince selected."

	viewer="$(which evince)"
	viewer_short_name="Evince"

}


chooseLibreOffice()
{

	#echo "LibreOffice selected."

	viewer="$(which libreoffice)"
	viewer_short_name="LibreOffice"

}


chooseMultimediaViewer()
{

	# Geeqie and Gthumb may have issues with clutter, so:
	viewer="$(which gwenview)"
	viewer_short_name="GwenView"

}


chooseEog()
{

	#echo "Eog selected."

	viewer="$(which eog)"
	viewer_short_name="Eog"

}


chooseFirefox()
{

	#echo "Firefox selected."

	viewer="$(which firefox)"
	viewer_short_name="Firefox"

}


chooseMplayer()
{

	#echo "Mplayer selected."

	viewer="$(which mplayer)"
	viewer_short_name="Mplayer"

}



chooseNedit()
{

	#echo "Nedit selected."

	# nedit:

	# Many names for nedit client/server: gentoo...
	NEDITC_GENTOO="$(which neditc 2>/dev/null | grep -v ridiculously 2>/dev/null)"

	# ...debian...
	NEDITC_DEBIAN="$(which nedit-nc 2>/dev/null | grep -v ridiculously 2>/dev/null)"

	# ...and others (nc can be netcat too)
	NC="$(which nc 2>/dev/null | grep -v ridiculously 2>/dev/null)"

	# Basic nedit, one full process by window:
	NEDIT="$(which nedit 2>/dev/null | grep -v ridiculously 2>/dev/null)"


	# Sets of X parameters common to all nedit members:
	NEDIT_FAMILY_OPT="-create -xrm nedit*text.background:black -xrm nedit*text.foreground:white -xrm nedit*text.lineNumForeground:red -xrm nedit*text.cursorForeground:white"

	NEDIT_NC_OPT="-noask"

	if [ -x "${NEDIT}" ]; then

		viewer="${NEDIT} ${NEDIT_FAMILY_OPT}"
		viewer_short_name="Nedit"
		multi_win=0

	fi

	if [ -x "${NC}" ]; then

		if ${NC} -h 2>/dev/null; then
		 # Not netcat:
			viewer="${NC} ${NEDIT_FAMILY_OPT} ${NEDIT_NC_OPT}"
			viewer_short_name="Nc"
			multi_win=0
	 # else: the nc being detected is netcat, not nedit tool: do nothing here.
		fi

	fi

	if [ -x "${NEDITC_GENTOO}" ]; then

		viewer="${NEDITC_GENTOO} ${NEDIT_FAMILY_OPT}"
		viewer_short_name="Neditc"
		multi_win=0

	fi

	if [ -x "${NEDITC_DEBIAN}" ]; then

		viewer="${NEDITC_DEBIAN} ${NEDIT_FAMILY_OPT} ${NEDIT_NC_OPT}"
		viewer_short_name="Nedit-nc"
		multi_win=0

	fi

}




# For the *emacs, we use a window width of 83 instead of 80 to compensate
# for the line numbers. However the length of that number depends on the
# number of lines (ex: more than 1000 lines implies 4 digits on the left).

chooseXemacs()
{

	#echo "Choosing xemacs"

	# xemacs:

	XEMACS="$(which xemacs 2>/dev/null | grep -v ridiculously 2>/dev/null)"

	if [ -x "${XEMACS}" ]; then
		viewer="${XEMACS} --geometry=83x60 "
		viewer_short_name="XEmacs"
		multi_win=0
	fi

}



chooseEmacs()
{

	#echo "Choosing emacs"

	# emacs: (allows, if no emacs server is running, to run a standalone
	# emacs instead, which itself will be a server thanks to its
	# '(server-start)' configuration.

	EMACS="$(which emacs 2>/dev/null | grep -v ridiculously 2>/dev/null)"

	if [ -x "${EMACS}" ]; then

		if [ $standalone -eq 1 ]; then

			EMACS_CLIENT="/bin/emacsclient"

			if [ ! -x "${EMACS_CLIENT}" ]; then

				EMACS_CLIENT="/usr/bin/emacsclient"

				if [ ! -x "${EMACS_CLIENT}" ]; then

					echo " Error, no emacs client available." 1>&2
					exit 55

				fi

			fi

			# Default:
			viewer="${EMACS_CLIENT}"
			viewer_opt="--alternate-editor=emacs"

		else

			if [ ! -x "${EMACS}" ]; then

				EMACS="/usr/bin/emacs"

				if [ ! -x "${EMACS}" ]; then

					echo " Error, no (standalone) emacs available." 1>&2
					exit 56

				fi

			fi

			viewer="${EMACS}"

		fi

		viewer_short_name="Emacs"

		multi_win=0

	fi

}



chooseNano()
{

	#echo "Choosing nano"

	# nano, text-based user-friendly viewer:
	NANO="$(which nano 2>/dev/null | grep -v ridiculously 2>/dev/null)"

	viewer="${NANO}"
	viewer_short_name="Nano"
	multi_win=1

}



chooseVim()
{

	#echo "Choosing VIM"

	# vi improved:
	VIM="$(which vim 2>/dev/null | grep -v ridiculously 2>/dev/null)"

	viewer="${VIM}"
	viewer_short_name="Vim"
	multi_win=1

}



chooseVi()
{

	#echo "Choosing VI"

	# Raw vi:
	VI="$(which vi 2>/dev/null | grep -v ridiculously 2>/dev/null)"

	viewer="${VI}"
	viewer_short_name="Vi"
	multi_win=1

}



chooseMore()
{

	#echo "Choosing more"

	MORE="$(which more 2>/dev/null | grep -v ridiculously 2>/dev/null)"

	viewer="${MORE}"
	viewer_short_name="more"
	multi_win=0

}





autoSelectViewer()
{

	# Take the best one (watch out the order!):

	viewer=""
	viewer_short_name=""

	chooseMore

	# multi_win=1


	# if [ "${do_X}" -eq 0 ]; then

	#	if [ $prefer_emacs -eq 0 ]; then

	#		if [ -z "$viewer" ]; then
	#			chooseEmacs
	#		fi

	#		if [ -z "$viewer" ]; then
	#			chooseXemacs
	#		fi

	#		if [ -z "$viewer" ]; then
	#			chooseNedit
	#		fi

	#	else

	#		if [ $prefer_nedit -eq 0 ]; then

	#			if [ -z "$viewer" ]; then
	#				chooseNedit
	#			fi

	#			if [ -z "$viewer" ]; then
	#				chooseEmacs
	#			fi

	#			if [ -z "$viewer" ]; then
	#				chooseXemacs
	#			fi

	#		else

	#			chooseEmacs

	#			if [ -z "$viewer" ]; then
	#				chooseXemacs
	#			fi

	#			if [ -z "$viewer" ]; then
	#				chooseNedit
	#			fi

	#		fi

	#	fi

	# fi

	# if [ -n "$viewer" ]; then
	#	return
	# fi


	# if [ -x "${NANO}" ]; then
	#	chooseNano
	#	return
	# fi


	# if [ -x "${VIM}" ]; then
	#	chooseVim
	#	return
	# fi


	# if [ -x "${VI}" ]; then
	#	chooseVi
	#	return
	# fi

}



applyViewer()
{

	#echo "multi_win = ${multi_win}"
	#echo "viewer_short_name = ${viewer_short_name}"
	#echo "viewer = ${viewer}"
	#echo "viewer_opt = ${viewer_opt}"

	if [ ! -x "${viewer}" ]; then

		echo "  Error, the '${viewer_short_name}' tool is not available." 1>&2
		exit 10

	fi

	# Let's hope the display is OK.

	# Open the files in parallel or sequentially:
	for f in ${parameters}; do

		if [ ! -f "$f" ]; then

			# Sometimes a filename followed by some garbage is specified
			# (ex: a regrep might return "class_X.erl:construct");
			# Here we try to fix the filename:

			new_f="$(echo $f| sed 's|:.*$||1')"

			if [ -f "${new_f}" ]; then

				   echo "  (non-existing file '$f' has been automatically translated to existing file '${new_f}')"

				   f="${new_f}"

			fi

		fi

		if [ -z "${DISPLAY}" ]; then
			echo "    Viewing $f with ${viewer_short_name} (no DISPLAY set)"
		else
			if [ "${DISPLAY}" = ":0.0" ]; then
				# No need to remind if default:
				echo "    Viewing $f with ${viewer_short_name}"
			else
				echo "    Viewing $f with ${viewer_short_name} (DISPLAY is '${DISPLAY}')"
			fi
		fi

		if [ ${multi_win} -eq 0 ]; then

			if [ "${viewer_short_name}" = "Emacs" ]; then
				# To get rid of silly message:
				# "(emacs:12040): GLib-WARNING **: g_set_prgname() called
				# multiple times"
				#echo ${viewer} ${viewer_opt} "$f"
				${viewer} ${viewer_opt} "$f" 1>/dev/null 2>&1 &

				# Small delay added, otherwise specifying multiple files
				# apparently may freeze emacs to death, loosing all pending
				# changes...
				#
				sleep 1

			else
				#${viewer} ${viewer_opt} "$f" 2>/dev/null &
				${viewer} ${viewer_opt} "$f" 2>/dev/null

			fi

			if [ "${viewer_short_name}" = "Nedit" ]; then
				sleep 1
			fi

		else

			# As not all tools can/shall be run in background:

			if [ $run_in_background -eq 0 ]; then

				#echo "Running ${viewer} in background..."
				${viewer} ${viewer_opt} "$f" 2>/dev/null &

			else

				#echo "Running ${viewer} ${viewer_opt} in foreground..."
				${viewer} ${viewer_opt} "$f"

			fi

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
	echo "MORE          = ${MORE}"
	echo

}



# Main section.


do_X=0
do_show=1
do_force_nedit=1
do_find=1
do_locate=1


if [ "$1" = "${no_x_opt}" ]; then
	do_X=1
	shift
fi


if [ "$1" = "${show_opt}" ]; then
	do_show=0
	shift
fi


if [ "$1" = "-e" ] || [ "$1" = "--emacs" ]; then
	prefer_emacs=1
	prefer_nedit=0
	echo "(requested to prefer emacs over other viewers)"
	shift
fi


if [ "$1" = "-n" ] || [ "$1" = "--nedit" ]; then
	prefer_emacs=0
	prefer_nedit=1
	echo "(requested to prefer nedit over other viewers)"
	shift
fi


if [ "$1" = "-s" ] || [ "$1" = "--standalone" ]; then
	standalone=0
	shift
fi

if [ "$1" = "-f" ] || [ "$1" = "--find" ]; then
	do_find=0
	shift
fi

if [ "$1" = "-l" ] || [ "$1" = "--locate" ]; then
	do_locate=0
	shift
fi


if [ "$1" = "--help" ] || [ "$1" = "-h" ]; then
	echo "${usage}"
	exit 0
fi


if [ -z "$1" ]; then
	if [ ${do_show} -eq 1 ]; then
		echo "${usage}"
		exit 1
	fi
fi


if [ ${do_show} -eq 0 ]; then
	displayViewers
fi

# A problem is that if a specified file includes spaces (ex: 'hello world.txt'),
# then apparently there is no easy way in sh to preserve that space (the script
# will understand that two files are listed, 'hello' and 'world.txt').
#
# See
# https://unix.stackexchange.com/questions/131766/why-does-my-shell-script-choke-on-whitespace-or-other-special-characters for more details.


# Assigned only here to take into account the previous shifts:

# Not done anymore, as loses spaces:
#remaining_parameters="$@"
#echo "remaining_parameters = $remaining_parameters"

parameters=""

# Last filtering:
#for arg in $remaining_parameters; do
for arg in "$@"; do

	if [ "$arg" = "-s" ]; then

		standalone=0

	else

		# Here $arg is still right:
		#echo "arg=$arg"

		# But then the information is lost when:
		parameters="${parameters} ${arg}"

	fi

done

# Last test regarding bloody spaces included in filenames:
#for p in ${parameters}; do echo "- parameter: '$p'"; done
#exit

if [ $standalone -eq 0 ]; then

	echo "  (standalone mode activated)"

fi


if [ $do_find -eq 0 ]; then

	# Single file assumed, any initial whitespace removed:
	target_file="$(echo "${parameters}" | sed 's|^ ||1' | sed 's|:.*$||1')"
	#echo "target_file = ${target_file}"

	target_path="$(find . -name ${target_file})"

	if [ -z "${target_path}" ]; then

		echo "  (file '${target_file}' not found, nothing done)"

	else

		echo "  (file '${target_file}' found as '${target_path}')"

	fi

	parameters="${target_path}"

fi


if [ $do_locate -eq 0 ]; then

	# Single file assumed, any initial whitespace removed:
	target_file="$(echo ${parameters} | sed 's|^ ||1' | sed 's|:.*$||1')"
	#echo "target_file = ${target_file}"

	target_path="$(/bin/locate --limit 1 --existing ${target_file})"

	if [ -z "${target_path}" ]; then

		echo "  (file '${target_file}' not found, nothing done)"

	else

		echo "  (file '${target_file}' found as '${target_path}')"

	fi

	parameters="${target_path}"

fi




# Default:
multi_win=1

# Special-case for directories:
if [ -d "$1" ]; then

	chooseMultimediaViewer

	dir="$1"

	${viewer} ${viewer_opt} "${dir}" 1>/dev/null 2>&1 &

	exit

fi

# In case of a *list* of filenames, the detected extension will be the one of
# the last filename:
#
extension="$(echo ${parameters}| sed 's|^.*\.||1')"
#extension="$(echo $1| sed 's|^.*\.||1')"


#echo "parameters = ${parameters}"
#echo "extension = ${extension}"



# Deactivated for the moment:
#
#if [ "${extension}" = "erl" ]; then
#
#	chooseJedit
#	applyViewer
#	exit 0
#
#fi

if [ "${extension}" = "pdf" ] || [ "${extension}" = "PDF" ]; then

	chooseEvince
	applyViewer
	exit 0

fi

if [ "${extension}" = "odg" ] || [ "${extension}" = "odt" ] || [ "${extension}" = "rtf" ] || [ "${extension}" = "doc" ] || [ "${extension}" = "docx" ] || [ "${extension}" = "xls" ] || [ "${extension}" = "xlsx" ] || [ "${extension}" = "ppt" ] || [ "${extension}" = "pptx" ]; then

	chooseLibreOffice
	applyViewer
	exit 0

fi

if [ "${extension}" = "png" ]; then

	chooseEog
	applyViewer
	exit 0

fi


if [ "${extension}" = "jpeg" -o "${extension}" = "jpg" ]; then

	chooseEog
	applyViewer
	exit 0

fi


if [ "${extension}" = "svg" -o "${extension}" = "svgz" ]; then

	chooseEog
	applyViewer
	exit 0

fi


if [ "${extension}" = "json" ] || [ "${extension}" = "JSON" ]; then

	viewer="$(which jq 2>/dev/null)"

	if [ -x "${viewer}" ]; then

		viewer_opt="."
		viewer_short_name="jq"
		applyViewer
		exit 0

	else

		echo "Warning: no 'jq' tool available, defaulting to Emacs." 1>&2
		chooseEmacs
		applyViewer
		exit 0

	fi

fi



if [ "${extension}" = "html" ]; then

	chooseFirefox
	applyViewer
	exit 0

fi

if [ "${extension}" = "ogg" ] || [ "${extension}" = "wav" ] || [ "${extension}" = "mp3" ] || [ "${extension}" = "mp4" ] || [ "${extension}" = "flv" ] || [ "${extension}" = "m4v" ] || [ "${extension}" = "mkv" ] || [ "${extension}" = "avi" ]; then

	# Another option is: vlc.

	chooseMplayer

	# Otherwise difficult to control/stop:
	run_in_background=1

	applyViewer

	exit 0

fi


if [ "${extension}" = "dia" ]; then

	viewer="$(which dia)"
	viewer_short_name="dia"
	applyViewer
	exit 0

fi


if [ "${extension}" = "gz" ] || [ "${extension}" = "xz" ] || [ "${extension}" = "zip" ]; then

	# Is it a compressed trace file?
	if echo ${parameters}| grep '.traces' 1>/dev/null; then
		# In this case trigger next clause, as LogMX can handle it:
		extension="traces"
	fi

fi


if [ "${extension}" = "traces" ]; then

	LOGMX="$(which logmx.sh)"

	if [ ! -x "${LOGMX}" ]; then

		echo "  (no LogMX found, using default viewer for traces)"

	else

		viewer="${LOGMX}"
		viewer_short_name="LogMX"

	fi

	applyViewer
	exit 0

fi


autoSelectViewer

if [ ${do_show} -eq 0 ]; then

	echo "Chosen viewer: ${viewer_short_name}"
	echo "Complete viewer command: ${viewer} ${viewer_opt}"
	echo "Multiwin: ${multi_win}"
	exit

fi


if [ -z "${viewer}" ]; then

	echo "  Error, none of the registered viewers (neditc, nc, nedit, nano, vim, vi or more) can be used. Stopping now." 1>&2
	exit 1

fi

#echo "Applying finally the viewer"

applyViewer
