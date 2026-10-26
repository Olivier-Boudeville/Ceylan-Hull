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

	# Worse:
	#browser_exec="$(which chromium 2>/dev/null)"
	##echo "Chromium selected."
	#browser_exec_short_name="Chromium"

fi

#echo "Launching ${browser_exec_short_name} with arguments: $*..."

#"${browser_exec}" $* 1>/dev/null &

# Now flagging the selected browser as first target (rather than the Window
# Manager as a whole...) whenever the kernel needs to kill processes to regain
# RAM:
#
systemd-run --user --unit=hull-browser-oom --property=OOMScoreAdjust=500 --collect "${browser_exec}" $*

# Displaying resulting OOM scores:
#for p in $(pgrep -f "${browser_exec}"); do printf '%s ' "$p"; cat "/proc/$p/oom_score_adj" 2>/dev/null; done
