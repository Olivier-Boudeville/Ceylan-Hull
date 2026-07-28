#!/bin/sh

# Copyright (C) 2026-2026 Olivier Boudeville
#
# Author: Olivier Boudeville [olivier (dot) boudeville (at) esperide (dot) com]
#
# This file is part of the Ceylan-Hull toolbox (see http://hull.esperide.org).


usage="Usage: $(basename $0): starts a full SNCF Internet (wifi-based) connectivity"


# Setting here, thus must be root:
if [ ! $(id -u) -eq 0 ]; then

    echo "  Error, this script must be run as root." 1>&2
    exit 5

fi


wifi_script_name="manage-wifi.sh"

wifi_script="$(which ${wifi_script_name} 2>/dev/null)"

if [ ! -x "${wifi_script}" ]; then
    echo "  Error, our script to manage wifi (${wifi_script_name}) was not found." 1>&2
    exit 10
fi


netctl="$(which netctl 2>/dev/null)"

if [ ! -x "${netctl}" ]; then
    echo "  Error, no 'netctl' executable found." 1>&2
    exit 15
fi


browser_script_name="launch-browser.sh"

browser_script="$(which ${browser_script_name} 2>/dev/null)"

if [ ! -x "${browser_script}" ]; then
    echo "  Error, our script to launch a browser (${browser_script_name}) was not found." 1>&2
    exit 20
fi


if ! "${wifi_script}" start; then
	echo "Error, starting the wifi failed." 1>&2
    exit 25
fi


if ! "${netctl}" start sncf-inoui-wifi; then
	echo "Error, starting the wifi failed." 1>&2
    exit 30
fi

# Browsers cannot/should not be run as root:
#if ! "${browser_script}" https://wifi.sncf; then
#   echo "Error, launching the browser failed." 1>&2
#   exit 35
#fi

printf "Now just run, as a regular user: '${browser_script} https://wifi.sncf', and enjoy!"
