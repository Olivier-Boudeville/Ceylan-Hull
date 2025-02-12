#!/bin/sh


# Copyright (C) 2010-2025 Olivier Boudeville
#
# Author: Olivier Boudeville [olivier (dot) boudeville (at) esperide (dot) com]
#
# This file is part of the Ceylan-Hull toolbox.


# This script has for purpose to *edit* (hence its name, 'e') files, so it opens
# them (as read/write) with a relevant tool.


# See also:
# - the 'v' ('view') script
# - the 'xdg-open' command


no_x_opt="--noX"
show_opt="--display"


usage="Usage: $(basename $0) [${no_x_opt}] [${show_opt}] [-h|--help] [-e|--emacs] [-n|--nedit] [-f|--find] [-s|--standalone] file1 file2 ...:

  Opens for reading/writing the set of specified files with the 'best' available editor.

  Options are:
   '${no_x_opt}' to prevent selecting a graphical editor, notably if there is no available X display (can also be disabled once for all in the environment by setting the HULL_NO_GRAPHICAL_OUTPUT variable to the 0 value)
   '${show_opt}' to display only the chosen settings (not executing them)
   '-e' or '--emacs' to prefer Emacs over all other auto-selected editors
   '-n' or '--nedit' to prefer Nedit over all other auto-selected editors
   '-f' or '--find' to first look-up specified file from current directory, before opening it
   '-s' or '--standalone' to prefer not using the server-based version of the selected editor, if applicable (useful to avoid reusing any already opened window)
   '-l' or '--locate' to open the single file (if any) found thanks to 'locate'
"

# Note: a special syntax is recognised as well: 'e A_FILE -s', which is
# convenient when wanting to open a file yet thinking last that this should be
# done in another window.


editor=""

# Not to be directly included in the editor variable, so that it can be still
# tested with -x for example.
#
editor_opt=""


# Defaults:
prefer_emacs=1
prefer_nedit=1

# Tells whether we want to launch a standalone editor (default: no):
standalone=1


# Useful to discriminate between tools (graphical ones shall be run in
# background, whereas in-terminal ones not) and contexts of use (e.g. emacs may
# a graphical tool if X support is available, whereas it would be an in-terminal
# one on an headless server):
#
run_in_background=0

# May not be defined:
if [ "${HULL_NO_GRAPHICAL_OUTPUT}" = "0" ]; then
	# If in text-only mode, one foreground editor instance per console:
	run_in_background=1
fi


# Function section.


chooseJedit()
{

	#echo "Jedit selected."

	JEDIT="$(which jedit 2>/dev/null)"

	if [ -x "${JEDIT}" ]; then
		editor="${JEDIT}"
		editor_short_name="Jedit"
		multi_win=0
	fi

}


chooseLibreOffice()
{

	#echo "LibreOffice selected."

	editor="$(which libreoffice 2>/dev/null)"
	editor_short_name="LibreOffice"

}


chooseGimp()
{

	#echo "Gimp selected."

	editor="$(which gimp 2>/dev/null)"
	editor_short_name="The Gimp"

}


chooseJupyter()
{

	#echo "Jupyter-notebook selected."

	# A Mamba environment may be activated first.

	editor="$(which jupyter-notebook 2>/dev/null)"
	editor_short_name="Jupyter notebook"

}


chooseBlender()
{

	#echo "Blender selected."

	editor="$(which blender 2>/dev/null)"
	editor_short_name="Blender"

}


chooseBlenderImporter()
{

	#echo "Blender importer selected."

	editor="$(which blender-import.sh 2>/dev/null)"
	editor_short_name="Blender importer"

}


chooseInkscape()
{

	#echo "Inkscape selected."

	editor="$(which inkscape 2>/dev/null)"
	editor_short_name="Inkscape"

}


chooseNedit()
{

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
		editor="${NEDIT}"
		editor_opt="${NEDIT_FAMILY_OPT}"
		editor_short_name="Nedit"
		multi_win=0
	fi

	if [ -x "${NC}" ]; then
		if ${NC} -h 2>/dev/null; then
		 # Not netcat:
			editor="${NC}"
			editor_opt="${NEDIT_FAMILY_OPT} ${NEDIT_NC_OPT}"
			editor_short_name="Nc"
			multi_win=0
		# else: the nc being detected is netcat, not nedit tool: do nothing
		# here.
		fi
	fi

	if [ -x "${NEDITC_GENTOO}" ]; then
		editor="${NEDITC_GENTOO}"
		editor_opt="${NEDIT_FAMILY_OPT}"
		editor_short_name="Neditc"
		multi_win=0
	fi

	if [ -x "${NEDITC_DEBIAN}" ]; then
		editor="${NEDITC_DEBIAN}"
		editor_opt="${NEDIT_FAMILY_OPT} ${NEDIT_NC_OPT}"
		editor_short_name="Nedit-nc"
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
		editor="${XEMACS}"
		editor_opt="--geometry=83x60 "
		editor_short_name="XEmacs"
		multi_win=0
	fi

}



chooseEmacs()
{

	#echo "Choosing emacs"

	# emacs: (allows, if no emacs server is running, to run a standalone
	# emacs instead, which itself will be a server thanks to its
	# '(server-start)' configuration.

	EMACS="$(which emacs 2>/dev/null 2>/dev/null)"

	# A note about emacsclient: on Windows/MSYS2, this executable can be found
	# either in /bin and /usr/bin, or in /mingw64/bin (unfortunately in a
	# different version).
	#
	# Special care must be done in order not to mix origins/versions for emacs
	# and emacsclient, otherwise for example the first file may be opened
	# whereas the next ones will be deemed (wrongly) non-existing and thus to be
	# created.
	#
	# So, EMACS being found with 'which', the same shall be done for EMACSCLIENT
	# (so no tests with hardcoded paths shall be used here)

	if [ -x "${EMACS}" ]; then

		editor_short_name="Emacs"

		if [ $run_in_background -eq 0 ]; then

			# Finally emacsclient seems always available with graphical emacs,
			# and seems more relevant generally:
			#
			EMACS_CLIENT="$(which emacsclient 2>/dev/null)"

			if [ ! -x "${EMACS_CLIENT}" ]; then

				echo " Error, no emacs client available." 1>&2
				exit 55

			fi

			editor="${EMACS_CLIENT}"
			multi_win=0

			if [ $standalone -eq 0 ]; then

				# Tried with no luck: -a '' or --daemon:
				editor_opt="--create-frame --alternate-editor=emacs"

			else

				editor_opt="--alternate-editor=emacs"

			fi

		else

			# Shall run in a terminal, typically if being on an headless server:
			editor="${EMACS}"
			#editor_opt="--create-frame"
			multi_win=1

		fi


		# run_in_background shall remain unchanged, as it is context-dependent
		# (e.g. whether X is available or not, see HULL_NO_GRAPHICAL_OUTPUT).

	else

		echo " Error, no (standalone) emacs available." 1>&2
		exit 56

	fi

}


chooseNano()
{

	#echo "Nano selected."

	# nano, text-based user-friendly editor:
	NANO="$(which nano 2>/dev/null)"

	editor="${NANO}"
	editor_short_name="Nano"
	multi_win=1

}


chooseVim()
{

	#echo "Choosing VIM"

	# vi improved:
	VIM="$(which vim 2>/dev/null)"

	editor="${VIM}"
	editor_short_name="Vim"
	multi_win=1

}



chooseVi()
{

	#echo "Choosing VI"

	# Raw vi:
	VI="$(which vi 2>/dev/null)"

	editor="${VI}"
	editor_short_name="Vi"
	multi_win=1

}



chooseGanttproject()
{

	GANTTPROJECT="$(which ganttproject 2>/dev/null)"

	editor="${GANTTPROJECT}"
	editor_short_name="Ganttproject"
	multi_win=1

}


autoSelectEditor()
{

	# Take the best one (watch out the order!):

	editor=""
	editor_short_name=""

	multi_win=1


	if [ "${do_X}" -eq 0 ]; then

		if [ $prefer_emacs -eq 0 ]; then

			if [ -z "${editor}" ]; then
				chooseEmacs
			fi

			if [ -z "${editor}" ]; then
				chooseXemacs
			fi

			if [ -z "${editor}" ]; then
				chooseNedit
			fi

		else

			if [ $prefer_nedit -eq 0 ]; then

				if [ -z "${editor}" ]; then
					chooseNedit
				fi

				if [ -z "${editor}" ]; then
					chooseEmacs
				fi

				if [ -z "${editor}" ]; then
					chooseXemacs
				fi

			else

				chooseEmacs

				if [ -z "${editor}" ]; then
					chooseXemacs
				fi

				if [ -z "${editor}" ]; then
					chooseNedit
				fi

			fi

		fi

	else

		#echo "Choosing Emacs here whereas no X here:"
		chooseEmacs
		run_in_background=1
		multi_win=1

	fi

	if [ -n "${editor}" ]; then
		return
	fi


	if [ -x "${NANO}" ]; then
		chooseNano
		return
	fi


	if [ -x "${VIM}" ]; then
		chooseVim
		return
	fi


	if [ -x "${VI}" ]; then
		chooseVi
		return
	fi

}



applyEditor()
{

	if [ $verbose -eq 0 ]; then
		echo "editor_short_name = ${editor_short_name}"
		echo "editor = ${editor}"
		echo "editor_opt = ${editor_opt}"
		echo "do_X = ${do_X}"
		echo "DISPLAY = ${DISPLAY}"
		echo "multi_win = ${multi_win}"
		echo "run_in_background = ${run_in_background}"
	fi

	if [ ! -x "${editor}" ]; then

		echo "  Error, the '${editor_short_name}' tool is not available (no '${editor}')." 1>&2

		exit 10

	fi

	# Let's hope the display is OK.

	# Allows not to sleep if a single file is opened (usual case):
	first_file=0

	# Open the files in parallel or sequentially:
	for f in ${parameters}; do

		# The user may specify 'some_file.ext' whereas a
		# 'some_file.ext.template' file exists. In this case, we consider that
		# the former is generated from the latter, and thus the latter (the
		# template) shall be edited instead, so:
		#
		template_file="$f.template"

		if [ -f "${template_file}" ]; then

			echo "## Warning: '$f' was requested to be edited, whereas '${template_file}' exists; editing the latter one instead." 1>&2

			f="${template_file}"

		elif [ ! -f "$f" ]; then

			# Sometimes a filename followed by some garbage is specified
			# (e.g. a regrep might return "class_X.erl:construct");
			# Here we try to fix the filename - should such a file exist:

			new_f="$(echo "$f"| sed 's|:.*$||1')"

			#echo "- specified filename: ${f}"
			#echo "- translated filename: ${new_f}"
			#exit

			if [ -f "${new_f}" ]; then

				   echo "  (non-existing file '$f' has been automatically translated to existing file '${new_f}')"

				   f="${new_f}"

			else

				# In some cases (e.g. find-record-definition.sh) we have a
				# trailing dash to remove:
				#
				# Not as simple as:
				# new_f=$(echo "$f" | sed 's|-.*$||1')
				#
				# (since there might be multiple dashes in $f; the last - not
				# first - shall be taken into account as the first character to
				# remove)
				#
				new_f="$(echo "$f" | sed -n 's|\(.*\)-.*|\1|p')"

				if [ -f "${new_f}" ]; then

				   echo "  (non-existing file '$f' has been automatically translated to existing file '${new_f}')"

				   f="${new_f}"

				fi

			fi

		fi

		if [ -z "${DISPLAY}" ]; then
			echo "    Editing $f with ${editor_short_name} (no DISPLAY set)"
		else
			echo "    Editing $f with ${editor_short_name} (DISPLAY is <${DISPLAY}>)"
		fi

		if [ ${multi_win} -eq 0 ]; then

			if [ "${editor_short_name}" = "Emacs" ]; then

				# To get rid of silly message:
				# "(emacs:12040): GLib-WARNING **: g_set_prgname() called
				# multiple times"
				#
				[ $verbose -eq 1 ] || echo "Running (multiwin) '${editor} ${editor_opt} $f'..."
				${editor} ${editor_opt} "$f" 1>/dev/null 2>&1 &

				# Small delay added, otherwise specifying multiple files
				# apparently may freeze emacs to death, losing all pending
				# changes...
				#
				if [ $first_file -eq 0 ]; then
					first_file=1
				else
					sleep 1
				fi

			else

				# May not be put in the background either:
				if [ $run_in_background -eq 0 ]; then

					# Ever happens?
					[ $verbose -eq 1 ] || echo "Running (monowin, in background) '${editor} ${editor_opt} $f'..."
					${editor} ${editor_opt} "$f" 1>/dev/null 2>&1 &

				else
					[ $verbose -eq 1 ] || echo "Running (monowin, in foreground) '${editor} ${editor_opt} $f'..."
					${editor} ${editor_opt} "$f" 1>/dev/null 2>&1

				fi

			fi

		else

			# As not all tools can/shall be run in background:

			if [ $run_in_background -eq 0 ]; then

				[ $verbose -eq 1 ] || echo "Running '${editor} ${editor_opt} $f' in background..."
				${editor} ${editor_opt} "$f" 2>/dev/null &

			else

				[ $verbose -eq 1 ] || echo "Running '${editor} ${editor_opt} $f' in foreground..."
				${editor} ${editor_opt} "$f" 2>/dev/null

			fi

		fi

	done

}



displayEditors()
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
do_find=1
do_locate=1


# To debug:
verbose=1
#verbose=0


# By default, a graphical editor will be used, unless the option specified in
# no_x_opt has been set, or if the HULL_NO_GRAPHICAL_OUTPUT environment variable
# has been set to 0, to prevent an attempt to launch a graphical tool from a
# user not allowed (like root in some rare cases) and/or from a computer without
# X support (most servers), in which case one may add then add on a per-host
# basis, in /etc/bash.bashrc:
#
# """
# # No X support wanted on an headless server:
# export HULL_NO_GRAPHICAL_OUTPUT=0
# """
#

if [ "$1" = "${no_x_opt}" ]; then
	do_X=1
	shift
fi


# Might not be defined at all:
if [ "${HULL_NO_GRAPHICAL_OUTPUT}" = "0" ]; then
	[ $verbose -eq 1 ] || echo "Disabling X support, as HULL_NO_GRAPHICAL_OUTPUT was set."
	do_X=1
else
	[ $verbose -eq 1 ] || echo "(HULL_NO_GRAPHICAL_OUTPUT not set to 0)"
fi


if [ "$1" = "${show_opt}" ]; then
	do_show=0
	shift
fi


if [ "$1" = "-e" ] || [ "$1" = "--emacs" ]; then
	prefer_emacs=1
	prefer_nedit=0
	echo "(requested to prefer Emacs over other editors)"
	shift
fi


if [ "$1" = "-n" ] || [ "$1" = "--nedit" ]; then
	prefer_emacs=0
	prefer_nedit=1
	echo "(requested to prefer Nedit over other editors)"
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
	echo "
${usage}"
	exit 0
fi


if [ -z "$1" ]; then
	if [ ${do_show} -eq 1 ]; then
		echo "Error, no parameter specified.
${usage}" 1>&2
		exit 5
	fi
fi


if [ ${do_show} -eq 0 ]; then
	displayEditors
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
#echo "remaining_parameters = $remaining_parameters"

parameters=""

# Last filtering:
#for arg in $remaining_parameters; do
for arg in "$@"; do

	if [ "${arg}" = "-s" ]; then

		standalone=0

	else

		# Here $arg is still right:
		#echo "arg=$arg"

		# But then the information is lost when:
		# (avoiding any intial space)
		#
		if [ -z "${parameters}" ]; then
			parameters="${arg}"
		else
			parameters="${parameters} ${arg}"
		fi

	fi

done

#echo "A: parameters = '$parameters'"

# Last test regarding bloody spaces included in filenames:
#for p in ${parameters}; do echo "- parameter: '$p'"; done
#exit

if [ $standalone -eq 0 ]; then

	echo "  (standalone mode activated)"

fi


if [ $do_find -eq 0 ]; then

	# Single file assumed, any initial whitespace removed:
	target_file=$(echo "${parameters}" | sed 's|^ ||1' | sed 's|:.*$||1')
	#echo "target_file = ${target_file}"

	if echo "${target_file}" | grep / 1>/dev/null 2>&1; then

		# Otherwise: "find: warning: ‘-name’ matches against basenames only, but
		# the given pattern contains a directory separator (‘/’), thus the
		# expression will evaluate to false all the time.  Did you mean
		# ‘-wholename’?
		#
		#echo " Error, the deduced target file to be found is '${target_file}', whereas no directory separator is allowed here." 1>&2

		#exit 80

		new_target_file=$(basename ${target_file})

		if [ "${new_target_file}" = "${target_file}" ]; then

			echo " Error, unable to determine the file to lookup from deduced target file '${target_file}', which contains a directory separator." 1>&2
			exit 85

		else

			#echo "The deduced target file to be found, '${target_file}', contains a directory separator. Looking up '${new_target_file}'."

			target_file="${new_target_file}"

		fi

	fi

	target_path="$(find . -name "${target_file}")"

	if [ -z "${target_path}" ]; then

		echo "  (file '${target_file}' not found, nothing done)"

	else

		# Detect if more than one path was found:
		found_count="$(echo ${target_path} | wc -w)"

		if [ ! "${found_count}" = 1 ]; then

			echo "  Error, expecting to find a single entry named '${target_file}', yet found: '${target_path}'." 1>&2

			exit 65

		fi

		echo "  (file '${target_file}' found as '${target_path}')"

	fi

	parameters="${target_path}"

fi


if [ $do_locate -eq 0 ]; then

	# Single file assumed, any initial whitespace removed:
	target_file="$(echo "${parameters}" | sed 's|^ ||1' | sed 's|:.*$||1')"
	#echo "target_file = ${target_file}"

	target_path="$(/bin/locate --existing ${target_file} | grep -v .emacs.d/myriad-backups)"

	#echo "target_path = ${target_path}"

	if [ -z "${target_path}" ]; then

		echo "  (file '${target_file}' not found, nothing done)"

	else

		path_count=$(echo ${target_path} | wc -w)
		#echo "path_count = ${path_count}"

		if [ ${path_count} -gt 1 ]; then

			echo "  Error, multiple (${path_count}) paths found for '${target_file}': ${target_path}" 1>&2
			exit 105

		fi

		echo "  (file '${target_file}' found as '${target_path}')"

	fi

	parameters="${target_path}"

fi


#echo "B: parameters = '$parameters'"


# Default:
multi_win=1


# In case of a *list* of filenames, the detected extension will be the one of
# the last filename:
#
extension="$(echo ${parameters}| sed 's|^.*\.||1' | tr '[:upper:]' '[:lower:]')"
#extension=$(echo $1| sed 's|^.*\.||1' | tr '[:upper:]' '[:lower:]')


#echo "C: parameters = '${parameters}'"
#echo "C: extension = '${extension}'"


if [ ${prefer_emacs} -eq 1 ] && [ ${prefer_nedit} -eq 1 ]; then

	if [ "${extension}" = "pdf" ] || [ "${extension}" = "djvu" ] || [ "${extension}" = "epub" ]; then

		echo "  Warning: do you really want to *edit* this rich-text file (not just display it)? (y/n) [n]"
		read answer
		if [ "${answer}" = "y" ] || [ "${answer}" = "Y" ]; then

			chooseLibreOffice
			applyEditor
			exit 0

		else

			# Just a display then:
			v ${parameters}
			exit 0

		fi

	fi


	if [ "${extension}" = "odt" ] || [ "${extension}" = "odg" ] || [ "${extension}" = "ods" ]|| [ "${extension}" = "rtf" ] || [ "${extension}" = "doc" ] || [ "${extension}" = "docx" ] || [ "${extension}" = "xls" ] || [ "${extension}" = "xlsx" ] || [ "${extension}" = "ppt" ] || [ "${extension}" = "pptx" ]; then

		chooseLibreOffice
		applyEditor
		exit 0

	fi


	if [ "${extension}" = "png" ] || [ "${extension}" = "jpeg" ] || [ "${extension}" = "jpg" ] || [ "${extension}" = "bmp" ] || [ "${extension}" = "tif" ] || [ "${extension}" = "tga" ] || [ "${extension}" = "gif" ] || [ "${extension}" = "webp" ] || [ "${extension}" = "xcf" ]; then

		chooseGimp
		applyEditor
		exit 0

	fi


	# Only done as below in 'v'; here we just want to edit the Jupyter file:
	#if [ "${extension}" = "ipynb" ]; then
	#
	#	chooseJupyter
	#	applyEditor
	#	exit 0
	#
	#fi


	if [ "${extension}" = "blend" ]; then

		chooseBlender
		applyEditor
		exit 0

	fi

	# Blender will not open them, they must be imported instead:
	if [ "${extension}" = "gltf" ] || [ "${extension}" = "glb" ] || [ "${extension}" = "dae" ] || [ "${extension}" = "fbx" ] || [ "${extension}" = "ifc" ]; then

		chooseBlenderImporter
		applyEditor
		exit 0

	fi


	if [ "${extension}" = "template" ]; then

		chooseEmacs
		applyEditor
		exit 0

	fi


	if [ "${extension}" = "rst" ]; then

		chooseEmacs
		applyEditor
		exit 0

	fi


	if [ "${extension}" = "svg" ] || [ "${extension}" = "svgz" ]; then

		chooseInkscape
		applyEditor
		exit 0

	fi

	# No json-specified rule (e.g. 'jq' just a viewer).

	# HTML files are to be edited (hence no special case here)


	if [ "${extension}" = "ogg" ] || [ "${extension}" = "opus" ] || [ "${extension}" = "wav" ] || [ "${extension}" = "mp3" ] || [ "${extension}" = "mp4" ] || [ "${extension}" = "flv" ]; then

		editor="$(which audacity)"
		editor_short_name="Audacity"

		applyEditor

		exit 0

	fi


	if [ "${extension}" = "dia" ]; then

		editor="$(which dia)"
		editor_short_name="Dia"
		applyEditor
		exit 0

	fi


	if [ "${extension}" = "gz" ] || [ "${extension}" = "xz" ] || [ "${extension}" = "zip" ]; then

		# Is it a compressed trace file?
		if echo ${parameters} | grep '.traces' 1>/dev/null; then
			# In this case trigger next clause, as LogMX can handle it:
			extension="traces"
		fi

	fi


	if [ "${extension}" = "traces" ]; then

		# Editing here, not viewing:

		# LOGMX="$(which logmx.sh)"

		# if [ ! -x "${LOGMX}" ]; then

		#   echo "  (no LogMX found, using default editor for traces)"

		# else

		#   editor="${LOGMX}"
		#   editor_short_name="LogMX"

		# fi

		# applyEditor
		# exit 0

		chooseEmacs

	fi


	if [ "${extension}" = "gan" ]; then

		chooseGanttproject

		# Supposing a single filename (otherwise will look up files in
		# /opt/ganttproject rather than in current directory):

		#echo "D: parameters = '${parameters}'"

		parameters="$PWD/${parameters}"

		#echo "E: parameters = '${parameters}'"

		applyEditor
		exit 0

	fi

fi


autoSelectEditor

if [ ${do_show} -eq 0 ]; then

	echo "Chosen editor: ${editor_short_name}"
	echo "Complete editor command: ${editor} ${editor_opt}"
	echo "Multiwin: ${multi_win}"
	exit

fi


if [ -z "${editor}" ]; then

	echo "  Error, none of the registered editors (neditc, nc, nedit, nano, vim or vi) can be used. Stopping now." 1>&2
	exit 1

fi

#echo "Applying finally the editor"

applyEditor
