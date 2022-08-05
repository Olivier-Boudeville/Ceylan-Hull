#!/bin/sh

usage="Usage: $(basename $0) A_FILE: fixes whitespace problems in the specified file.
Useful to properly whitespace-format files that shall be committed (even if not using Emacs as editor of choice)."

# Refer to http://myriad.esperide.org/#emacs-settings for the prior
# configuration of Emacs.

if [ "$1" = "-h" ] || [ "$1" = "--help" ]; then

	echo "${usage}"
	exit

fi


target_file="$1"

if [ ! $# -eq 1 ]; then

	echo "  Error, exactly one parameter needed.
${usage}" 1>&2

	exit 5

fi


if [ ! -f "${target_file}" ]; then

	echo "  Error, file '${target_file}' not found." 1>&2
	exit 10

fi

#echo "Fixing '${target_file}'..."

emacs="$(which emacs 2>/dev/null)"

if [ ! -x "${emacs}" ]; then

	echo "  Error, emacs not found." 1>&2
	exit 15

fi


# Error output silenced to avoid for example "Ignoring unknown mode
# ‘erlang-mode’":
#
${emacs} "${target_file}" --batch --eval="(whitespace-cleanup)" -f save-buffer 1>/dev/null 2>&1

if [ ! $? -eq 0 ]; then

	echo "  Error, processing of '${target_file}' failed." 1>&2
	exit 20

fi

echo "  + file '${target_file}' cleaned up"

# Possibly created by emacs:
/bin/rm -f "${target_file}~" 2>/dev/null
