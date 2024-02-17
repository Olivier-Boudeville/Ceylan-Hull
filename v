#!/bin/sh

# Copyright (C) 2010-2024 Olivier Boudeville
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
Usage: $(basename $0) [${no_x_opt}] [${show_opt}] [-h|--help] [-e|--emacs] [-n|--nedit] [-f|--find] [-s|--standalone] FILE_ELEMENT_1 FILE_ELEMENT_2...: opens for reading the set of specified files (or directories) with the 'best' available viewer for each of them.

  Options are:
	  '${no_x_opt}' to prevent selecting a graphical viewer, notably if there is no available X display
	  '${show_opt}' to display only the chosen settings (not executing them)
	  '-e' or '--emacs' to prefer emacs over all other viewers (the default)
	  '-n' or '--nedit' to prefer nedit over all other viewers
	  '-f' or '--find' to first look-up specified file from current directory, before opening it
	  '-s' or '--standalone' to prefer not using the server-based version of the selected viewer, if applicable (useful to avoid reusing any already opened window)
	  '-l' or '--locate' to open the single file (if any) found thanks to 'locate'
"

# Note: a special syntax used to be recognised as well: 'v A_FILE -s', which is
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


# To be set to 0 to display extra information:
verbose=1
#verbose=0


# Function section.


chooseJedit()
{

	#echo "Jedit selected."

	JEDIT="$(which jedit 2>/dev/null)"

	if [ -x "${JEDIT}" ]; then
		viewer="${JEDIT}"
		viewer_short_name="Jedit"
		multi_win=0
	fi

}


chooseEvince()
{

	#echo "Evince selected."

	viewer="$(which evince 2>/dev/null)"
	viewer_short_name="Evince"

}


chooseLibreOffice()
{

	#echo "LibreOffice selected."

	viewer="$(which libreoffice 2>/dev/null)"
	viewer_short_name="LibreOffice"

}



# Image viewers

chooseEog()
{

	#echo "Eog selected."

	viewer="$(which eog 2>/dev/null)"
	viewer_short_name="Eog"

}


chooseGwenview()
{

	#echo "Gwenview selected."

	viewer="$(which gwenview 2>/dev/null)"
	viewer_short_name="Gwenview"

	if [ -z "${viewer}" ]; then
		chooseEog
	fi

}


chooseInkscape()
{

	#echo "Inkscape selected."

	viewer="$(which inkscape 2>/dev/null)"
	viewer_short_name="Inkscape"

}


chooseMultimediaViewer()
{

	# Geeqie and Gthumb may have issues with clutter, so:
	chooseGwenview

}


chooseF3d()
{

	#echo "F3D selected."

	viewer="$(which f3d 2>/dev/null)"
	viewer_short_name="F3D"
	viewer_opt="--verbose"

}


chooseBlender()
{

	#echo "Blender selected."

	viewer="$(which blender 2>/dev/null)"
	viewer_short_name="Blender"

}


chooseBlenderImporter()
{

	#echo "Blender importer selected."

	viewer="$(which blender-import.sh 2>/dev/null)"
	viewer_short_name="Blender importer"

}


chooseBrowser()
{

	#echo "Firefox selected."

	viewer="$(which firefox 2>/dev/null)"
	viewer_short_name="Firefox"

}


chooseVideoPlayer()
{

	viewer="$(which mpv 2>/dev/null)"

	if [ -x "${viewer}" ]; then

		#echo "mpv selected."

		viewer_short_name="mpv"

		viewer_opt="-quiet --msg-level=all=no"

		viewer_comment="press 'o' for OSD, 'f' to toggle fullscreen, left / right arrows for fast-backward / forward by steps of 5 seconds, down / up arrows for steps of 1 minute, '{' / '}' to double / halve the playback speed (backspace to reset it), 'p' and space to pause, 'm' to mute, 's' to take a screenshot, 'q' to quit"

	else

		viewer="$(which mplayer 2>/dev/null)"

		if [ -x "${viewer}" ]; then

			#echo "mplayer selected."
			viewer_short_name="mplayer"

			viewer_opt="-nolirc -quiet -msglevel all=0"

		else

			viewer="$(which cvlc 2>/dev/null)"

			if [ -x "${viewer}" ]; then

				#echo "cvlc selected."

				viewer_short_name="VLC"

				viewer_opt="--quiet --play-and-exit"

			else

				chooseBrowser

			fi

		fi

	fi

}


# Relying on our Ceylan-Hull's script; executing it directly (rather than
# through this script) shall be preferred though, as this offers more
# flexibility/options.
#
chooseAudioPlayer()
{

	#echo "PlayAudio selected."

	play_script_name="play-audio.sh"

	play_script="$(which ${play_script_name} 2>/dev/null)"

	if [ ! -x "${play_script}" ]; then

		echo "Warning: Ceylan-Hull's '${play_script_name}' not found, defaulting to Mplayer." 1>&2

		chooseVideoPlayer

	else

		viewer="${play_script}"
		viewer_short_name="Ceylan-Hull's '${play_script_name}'"

		# No simple way to display the usage notification of the player only
		# once, as each file to view is managed separately of the others (and it
		# is better that way).

		# Displays usage notification just once, not one time per file:
		#"${viewer}" --just-notification

		# For each of the next calls:
		#viewer_opt="--no-notification"

	fi

}



chooseNedit()
{

	#echo "Nedit selected."

	# nedit:

	# Many names for nedit client/server: gentoo...
	NEDITC_GENTOO="$(which neditc 2>/dev/null)"

	# ...debian...
	NEDITC_DEBIAN="$(which nedit-nc 2>/dev/null)"

	# ...and others (nc can be netcat too)
	NC="$(which nc 2>/dev/null)"

	# Basic nedit, one full process by window:
	NEDIT="$(which nedit 2>/dev/null)"


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



# For the *emacs, we use a window width of 83 instead of 80 to compensate for
# the line numbers. However the length of that number depends on the number of
# lines (e.g. more than 1000 lines implies 4 digits on the left).

chooseXemacs()
{

	#echo "Choosing xemacs"

	# xemacs:

	XEMACS="$(which xemacs 2>/dev/null)"

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

	EMACS="$(which emacs 2>/dev/null)"

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
	NANO="$(which nano 2>/dev/null)"

	viewer="${NANO}"
	viewer_short_name="Nano"
	multi_win=1

}


chooseVim()
{

	#echo "Choosing VIM"

	# vi improved:
	VIM="$(which vim 2>/dev/null)"

	viewer="${VIM}"
	viewer_short_name="Vim"
	multi_win=1

}


chooseVi()
{

	#echo "Choosing VI"

	# Raw vi:
	VI="$(which vi 2>/dev/null)"

	viewer="${VI}"
	viewer_short_name="Vi"
	multi_win=1

}


chooseMore()
{

	#echo "Choosing more"

	MORE="$(which more 2>/dev/null)"

	viewer="${MORE}"
	viewer_short_name="more"
	multi_win=0

}



autoSelectViewer()
{

	[ $verbose -eq 1 ] || echo "Auto-selecting viewer"

	#echo "Warning: auto-selecting viewer." 1>&2

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



# Applies the selected viewer to the element designated by the file_elem
# variable.
#
applyViewer()
{

	#echo "Applying viewer on ${file_elem}..."

	[ $verbose -eq 1 ] || (
		echo "multi_win = ${multi_win}";
		echo "viewer_short_name = ${viewer_short_name}";
		echo "viewer = ${viewer}";
		echo "viewer_opt = ${viewer_opt}" )

	# Empty in a function:
	#echo "\$@ = $@"

	# Garbled:
	#echo "parameters = ${parameters}"

	#echo "file_elem = ${file_elem}"

	if [ ! -x "${viewer}" ]; then

		echo "  Error, the '${viewer_short_name}' tool (searched as '${viewer}') is not available." 1>&2
		exit 10

	fi

	#echo "(viewer '${viewer_short_name}' found as '${viewer}')"

	# Let's hope any display needed is OK.

	# To separate each file managed in turn:
	#echo

	if [ -z "${DISPLAY}" ]; then

		echo "    Viewing '${file_elem}' with ${viewer_short_name} (no DISPLAY set)"

	else

		if [ "${DISPLAY}" = ":0.0" ]; then
			# No need to remind if default:
			echo "    Viewing '${file_elem}' with ${viewer_short_name}"
		else
			echo "    Viewing '${file_elem}' with ${viewer_short_name} (DISPLAY is '${DISPLAY}')"
		fi

	fi

	if [ ${multi_win} -eq 0 ]; then

		if [ "${viewer_short_name}" = "Emacs" ]; then

			# To get rid of silly message:
			# "(emacs:12040): GLib-WARNING **: g_set_prgname() called
			# multiple times"
			#
			[ $verbose -eq 1 ] || echo "case A: ${viewer} ${viewer_opt} ${file_elem}"
			"${viewer}" ${viewer_opt} "${file_elem}" 1>/dev/null 2>&1 &

			# Small delay added, otherwise specifying multiple files apparently
			# may freeze emacs to death, loosing all pending changes...
			#
			sleep 1

		else

			[ $verbose -eq 1 ] || echo "case B: ${viewer} ${viewer_opt} ${file_elem}"
			#"${viewer}" ${viewer_opt} "${file_elem}" 2>/dev/null &
			"${viewer}" ${viewer_opt} "${file_elem}" 2>/dev/null

		fi

		if [ "${viewer_short_name}" = "Nedit" ]; then
			sleep 1
		fi

	else

		# As not all tools can/shall be run in background:

		if [ $run_in_background -eq 0 ]; then

			#echo "Running ${viewer} in background..."
			[ $verbose -eq 1 ] || echo "case C: ${viewer} ${viewer_opt} ${file_elem}"
			"${viewer}" ${viewer_opt} "${file_elem}" 2>/dev/null &

		else

			#echo "Running ${viewer} ${viewer_opt} in foreground..."
			[ $verbose -eq 1 ] || echo "case D: ${viewer} ${viewer_opt} ${file_elem}"
			"{viewer}" ${viewer_opt} "${file_elem}"

		fi

	fi

	if [ -n "${viewer_comment}" ]; then
		echo "(${viewer_comment})"
	fi

	# So that a given file element is viewed only once, not twice:
	is_applied=0

}



displayViewers()
{

	echo "(displaying viewers)"

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




# Manages the (single) file element specified in $1.
view_selected_element()
{

	is_applied=1

	file_elem="$1"

	[ $verbose -eq 1 ] || echo "(viewing '${file_elem}')"
	# Tentative name clean-up:

	if [ ! -f "${file_elem}" ]; then

		# Sometimes a filename followed by some garbage is specified (e.g. a
		# regrep might return "class_X.erl:construct"); here we try to fix the
		# filename by removing all characters after the first semicolon; we also
		# remove any 'file://' prefix:

		new_file_elem="$(echo ${file_elem} | sed 's|^file://||1' | sed 's|:.*$||1')"

		if [ ! "${new_file_elem}" = "${file_elem}" ]; then

			echo "  (non-existing file '${file_elem}' has been automatically translated to file '${new_file_elem}')"

			file_elem="${new_file_elem}"

		fi

	fi

	#echo "file_elem=${file_elem}"

	if [ $do_find -eq 0 ]; then

		# Any initial whitespace removed:
		target_file="$(echo "${file_elem}" | sed 's|^ ||1' | sed 's|:.*$||1')"
		#echo "target_file = ${target_file}"

		target_path="$(find . -name "${target_file}")"

		if [ -z "${target_path}" ]; then

			echo "  (file '${target_file}' not found, nothing done)"

			exit 15

		else

			echo "  (file '${target_file}' found as '${target_path}')"

		fi

		file_elem="${target_path}"

	fi


	if [ $do_locate -eq 0 ]; then

		# Any initial whitespace removed:
		target_file="$(echo ${file_elem} | sed 's|^ ||1' | sed 's|:.*$||1')"
		#echo "target_file = ${target_file}"

		target_path="$(/bin/locate --limit 1 --existing "${target_file}")"
		#echo "target_path = ${target_path}"

		if [ -z "${target_path}" ]; then

			echo "  (file '${target_file}' not found, nothing done)"

		else

			echo "  (file '${target_file}' found as '${target_path}')"

		fi

		file_elem="${target_path}"

	fi

	# Default:
	multi_win=1

	# Special-case for directories:
	if [ -d "${file_elem}" ]; then

		chooseMultimediaViewer

		dir="${file_elem}"

		#echo "(viewing directory '${dir}')"

		#echo ${viewer} ${viewer_opt} "${dir}"
		${viewer} ${viewer_opt} "${dir}" 1>/dev/null 2>&1 &

		is_applied=0

	elif [ ! -f "${file_elem}" ]; then

		if [ -d "${file_elem}" ]; then

			# Supposedly we want to see the images in the specified directory:
			chooseEog
			applyViewer

		else

			echo "  Error, the target file to view, '${file_elem}', does not exist, or is neither a file nor a directory." 1>&2
			exit 15

		fi

	fi

	# Normalising all extensions to lowercase first:
	extension="$(echo ${file_elem} | sed 's|^.*\.||1' | tr '[:upper:]' '[:lower:]')"

	#extension="$(echo $@ | sed 's|^.*\.||1' | tr '[:upper:]' '[:lower:]')"
	#extension="$(echo $1| sed 's|^.*\.||1' | tr '[:upper:]' '[:lower:]')"

	#echo "file_elem = ${file_elem}"
	#echo "extension = ${extension}"

	# Deactivated for the moment:
	#
	#if [ "${extension}" = "erl" ]; then
	#
	#   chooseJedit
	#   applyViewer
	#   exit 0
	#
	#fi


	content_type="$(file -b ${file_elem} | sed 's| .*$||1')"
	#echo "content_type = ${content_type}"

	# Synonyms for extensions:
	if [ "${extension}" = "jpg" ] || [ "${extension}" = "jpeg" ]; then

		extension="jpeg"

	fi

	if [ "${content_type}" = "RIFF" ] && [ "${extension}" = "jpeg" ]; then

		# Extension being a dot then 3 or 4 letters:
		renamed_elem="$(echo ${file_elem} | sed 's|.\{3,4\}[a-zA-Z]$|.webp|1')"
		echo "Warning: file '${file_elem}' has a JPEG-related extension yet its content is RIFF: fixing its actual extension, renaming it to '${renamed_elem}'." 1>&2
		/bin/mv "${file_elem}" "${renamed_elem}"

		file_elem="${renamed_elem}"
		extension="webp"

	elif [ "${extension}" = "pdf" ]; then

		chooseEvince
		applyViewer

	elif [ "${extension}" = "odg" ] || [ "${extension}" = "odt" ] || [ "${extension}" = "rtf" ] || [ "${extension}" = "doc" ] || [ "${extension}" = "docx" ] || [ "${extension}" = "xls" ] || [ "${extension}" = "xlsx" ] || [ "${extension}" = "ppt" ] || [ "${extension}" = "pptx" ]; then

		chooseLibreOffice
		applyViewer

	elif [ "${extension}" = "png" ] || [ "${extension}" = "jpeg" ] || [ "${extension}" = "jpg" ] || [ "${extension}" = "svgz" ] || [ "${extension}" = "bmp" ] || [ "${extension}" = "gif" ] || [ "${extension}" = "tif" ] || [ "${extension}" = "webp" ] || [ "${extension}" = "tga" ]; then

		# Currently frequent problems with Eog:
		#chooseEog
		chooseGwenview

		applyViewer

	elif [ "${extension}" = "svg" ]; then

		# As at least sometimes eog fails to display them properly:
		#chooseGwenview
		chooseInkscape
		applyViewer

	elif [ "${extension}" = "ico" ]; then

		chooseBrowser
		applyViewer

	elif [ "${extension}" = "xml" ]; then

		viewer="$(which xmllint 2>/dev/null)"

		if [ -x "${viewer}" ]; then

			viewer_short_name="xmllint"
			run_in_background=1

			applyViewer

		else

			echo "Warning: no 'xmllint' tool available, defaulting to Emacs." 1>&2
			chooseEmacs
			applyViewer

		fi

	elif [ "${extension}" = "json" ]; then

		viewer="$(which jq 2>/dev/null)"

		if [ -x "${viewer}" ]; then

			viewer_opt="."
			viewer_short_name="jq"
			applyViewer

		else

			echo "Warning: no 'jq' tool available, defaulting to Emacs." 1>&2
			chooseEmacs
			applyViewer

		fi

	elif [ "${extension}" = "html" ]; then

		chooseBrowser
		applyViewer

	# Audio file:
	elif [ "${extension}" = "ogg" ] || [ "${extension}" = "opus" ] || [ "${extension}" = "wav" ] || [ "${extension}" = "mp3" ]; then

		chooseAudioPlayer

		# Otherwise difficult to control/stop:
		run_in_background=1

	# Video file:
	elif [ "${extension}" = "mp4" ] || [ "${extension}" = "flv" ] || [ "${extension}" = "m4v" ] || [ "${extension}" = "mkv" ] || [ "${extension}" = "avi" ] || [ "${extension}" = "webm" ]; then

		chooseVideoPlayer

	elif [ "${extension}" = "dia" ]; then

		viewer="$(which dia)"
		viewer_short_name="dia"
		applyViewer

	elif [ "${extension}" = "blend" ]; then

		chooseBlender
		applyViewer

	# Blender will not open them, they must be imported instead:
	elif [ "${extension}" = "gltf" ] || [ "${extension}" = "glb" ] || [ "${extension}" = "dae" ] || [ "${extension}" = "fbx" ]; then

		chooseF3d
		applyViewer

	# Blender will not open them, they must be imported instead:
	elif [ "${extension}" = "ifc" ]; then

		chooseBlenderImporter
		applyViewer

	elif [ "${extension}" = "gz" ] || [ "${extension}" = "xz" ] || [ "${extension}" = "zip" ]; then

		# Is it a compressed trace file?
		if echo "${file_elem}" | grep '.traces' 1>/dev/null; then
			# In this case trigger next clause, as LogMX can handle it:
			extension="traces"
		fi

	elif [ "${extension}" = "traces" ]; then

		LOGMX="$(which logmx.sh 2>/dev/null)"

		if [ ! -x "${LOGMX}" ]; then

			echo "  (no LogMX found, using Emacs for traces)"
			chooseEmacs

		else

			viewer="${LOGMX}"
			viewer_short_name="LogMX"

		fi

		applyViewer

	elif [ "${file_elem}" = "erl_crash.dump" ]; then

		# For example in
		# ~/Software/Erlang/Erlang-current-install/lib/erlang/cdv:
		#
		cdv="$(which cdv 2>/dev/null)"

		if [ ! -x "${cdv}" ]; then

			echo "  (no cdv tool found, using more for crash dumps)"
			chooseMore

		else

			viewer="${cdv}"
			viewer_short_name="Erlang's cdv"

		fi

	fi


	if [ -z "${viewer}" ]; then

		autoSelectViewer

	fi


	if [ ${do_show} -eq 0 ]; then

		echo "Chosen viewer: ${viewer_short_name}"
		echo "Complete viewer command: ${viewer} ${viewer_opt}"
		echo "Multiwin: ${multi_win}"
		exit 0

	fi

	#echo "Applying finally the viewer"

	if [ $is_applied -eq 1 ]; then
		applyViewer
	fi

	#echo "Is applied? $is_applied."

}



# Main section.

#echo "(starting script)"

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
		echo "${usage}" 1>&2
		exit 5
	fi
fi


if [ ${do_show} -eq 0 ]; then
	displayViewers
fi


if [ $standalone -eq 0 ]; then

	echo "  (standalone mode activated)"

fi

# A problem is that if a specified file includes spaces (e.g. 'hello
# world.txt'), then apparently there is no easy way in sh to preserve that space
# (the script will understand that two files are listed, 'hello' and
# 'world.txt').
#
# See
# https://unix.stackexchange.com/questions/131766/why-does-my-shell-script-choke-on-whitespace-or-other-special-characters for more details.


# Assigned only here to take into account the previous shifts:

# Not done anymore, as loses spaces:
#remaining_parameters="$@"
#echo "remaining_parameters = ${remaining_parameters}"

[ $verbose -eq 1 ] || echo "Parameters: $@"

# Only sane way of dealing with paths that may include spaces:
for file_elem in "$@"; do

	[ $verbose -eq 1 ] || echo " - parameter: ${file_elem}"

	# Never name a function 'view' or even 'view_element'...
	view_selected_element "${file_elem}"

done

# So we do not seem to be able to keep in a variable the information obtained
# after having iterated on $@. So we still use 'parameters', but set it exactly
# to "$@", and manage afterwards the fact that options (like "-s") may linger in
# it:

#echo "\$@ = $@"
#for p in "$@"; do echo "- @ parameter: '$p'"; done

#parameters="$@"
#echo "parameters = ${parameters}"

# Last test regarding bloody spaces included in filenames:
#for p in ${parameters}; do echo "- parameter: '$p'"; done
#exit

#echo "(end of viewing)"

exit 0
