#!/bin/sh

usage="Usage: $(basename $0) A_FILE: fixes whitespace problems into specified file.
Useful to properly format files that shall committed, even if not using Emacs as editor."

# Refer to http://myriad.esperide.org/#emacs-settings for the prior
# configuration of Emacs.

target_file="$1"

if [ ! $# -eq 1 ]; then

	echo "  Error, exactly one parameter needed." 1>&2
	echo "${usage}" 1>&2

	exit 5

fi



if [ ! -f "${target_file}" ]; then

	echo "  Error, file '${target_file}' not found." 1>&2
	exit 10

fi


emacs=$(which emacs 2>/dev/null)

if [ ! -x "${emacs}" ]; then

	echo "  Error, emacs not found." 1>&2
	exit 15

fi

${emacs} "${target_file}" --batch --eval="(whitespace-cleanup)" -f save-buffer 1>/dev/null 2>&1

if [ ! $? -eq 0 ]; then

	echo "  Error, processing of '${target_file}' failed." 1>&2
	exit 20

fi

echo "  + file '${target_file}' cleaned up"

# Possibly created by emacs:
/bin/rm -f "${target_file}~" 2>/dev/null
