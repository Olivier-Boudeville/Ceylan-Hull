#!/bin/sh

# Copyright (C) 2026-2026 Olivier Boudeville
#
# Author: Olivier Boudeville [olivier (dot) boudeville (at) esperide (dot) com]
#
# This file is part of the Ceylan-Hull toolbox (see http://hull.esperide.org).


usage="Usage: $(basename $0) ARGS: fires up a suitable terminal."

term_exec="$(which gnome-terminal 2>/dev/null)"

if [ -x "${term_exec}" ]; then

	#echo "Gnome-terminal selected."
	term_exec_short_name="Gnome terminal"

else

	# Ancient:
	term_exec="$(which xterm 2>/dev/null)"

	#echo "xterm selected."
	term_exec_short_name="xterm"

fi

echo "Launching ${term_exec_short_name} with arguments: $*..."

"${term_exec}" $* &
