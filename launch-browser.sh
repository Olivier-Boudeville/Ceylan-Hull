#!/bin/sh

# Copyright (C) 2026-2026 Olivier Boudeville
#
# Author: Olivier Boudeville [olivier (dot) boudeville (at) esperide (dot) com]
#
# This file is part of the Ceylan-Hull toolbox (see http://hull.esperide.org).


usage="Usage: $(basename $0) ARGS: fires up a suitable web browser, possibly with arguments (like any URLs to start with)."

browser_exec="$(which librewolf 2>/dev/null)"

if [ -x "${browser_exec}" ]; then

	#echo "LibreWolf selected."
	browser_exec_short_name="LibreWolf"

else

	browser_exec="$(which firefox 2>/dev/null)"

	#echo "Firefox selected."

	browser_exec_short_name="Firefox"

fi

echo "Launching ${browser_exec_short_name} with arguments: $*..."

"${browser_exec}" $* &
