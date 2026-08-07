#!/bin/sh

# Copyright (C) 2023-2026 Olivier Boudeville
#
# Author: Olivier Boudeville [olivier (dot) boudeville (at) esperide (dot) com]
#
# This file is part of the Ceylan-Hull toolbox (see http://hull.esperide.org).


usage="Usage: [.|source] $(basename $0) [-h|--help] [TITLE]: sets the title of the current terminal tab.

Useful as, for example, Gnome Terminal does not provide any graphical-based means of doing so.

If no title is specified, the uppercased version of the name of the current directory (not its whole path) will be used.

Depending on the system settings (i.e. with some dynamic titles), this script, when run as '$(basename $0) foo', may fail to update the title for good; in this case just source it, typically with '. $(basename $0) foo'."


if [ "$1" = "-h" ] || [ "$1" = "--help" ]; then

	echo "${usage}"

	exit

fi


if [ ! $# -le 1 ]; then

	echo "  Error, extra parameter(s) specified.
${usage}" 1>&2

	exit 5

fi


title="$1"

if [ -z "${title}" ]; then

	title="$(echo $(basename $(pwd)) | tr '[:lower:]' '[:upper:]')"

fi


# Should this terminal set its title dynamically.
#
# There is a problem, though: only a script-local version of this environment
# variable is set, and as soon as the script exits, the title returns to its
# dynamic version.
#
# Only solution is to source (not execute) such a script, or use an alias.
#
unset PROMPT_COMMAND 2>/dev/null

# For most shells:
unset -f precmd preexec 2>/dev/null

# If this shell uses such an update function:
unset -f __set_title 2>/dev/null

printf "\e]2;${title}\a" && echo "Terminal title updated to '${title}'."
