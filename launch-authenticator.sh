#!/bin/sh

# Copyright (C) 2026-2026 Olivier Boudeville
#
# Author: Olivier Boudeville [olivier (dot) boudeville (at) esperide (dot) com]
#
# This file is part of the Ceylan-Hull toolbox (see http://hull.esperide.org).


usage="Usage: $(basename $0) [-h|--help] ARGS: fires up a suitable TOTP-like authenticator, i.e. an application for generating two-factor authentication (2FA) codes."

if [ "$1" = "-h" ] || [ "$1" = "--help" ]; then

	echo ${usage}

	exit

fi


if [ ! $# -eq 0 ]; then

	echo "  Error, extra parameter(s) specified ('$*').
${usage}" 1>&2

	exit 15

fi


# Gnome authenticator:
# (see https://archlinux.org/packages/extra/x86_64/authenticator/)
#
auth_exec="$(which authenticator 2>/dev/null)"

if [ -x "${auth_exec}" ]; then

	#echo "Gnome authenticator selected."
	auth_exec_short_name="Gnome authenticator"

else

	#auth_exec="$(which  2>/dev/null)"

	#echo " selected."

	#auth_exec_short_name=""

	echo "  Error, no authenticator application found. On Arch Linux, one may install the (Gnome) 'authenticator' package." 1>&2

	exit 5

fi


echo "Launching ${auth_exec_short_name} with arguments: $*..."

"${auth_exec}" $* 1>/dev/null &
