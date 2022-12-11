#!/bin/sh

quiet_opt="--quiet"

usage="Usage: $(basename $0) [${quiet_opt}] A_FILE: fixes whitespace problems in the specified file.

Useful to properly whitespace-format files that shall be committed (even if not using Emacs as editor of choice)."

# Refer to http://myriad.esperide.org/#emacs-settings for the prior
# configuration of Emacs.

if [ "$1" = "-h" ] || [ "$1" = "--help" ]; then

	echo "${usage}"
	exit

fi

verbose=0

if [ "$1" = "${quiet_opt}" ]; then

	verbose=1
	shift

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

emacs="$(which emacs 2>/dev/null)"

if [ ! -x "${emacs}" ]; then

	echo "  Error, emacs not found." 1>&2
	exit 15

fi


#echo "Fixing '${target_file}'..."

# Error output silenced to avoid for example "Ignoring unknown mode
# ‘erlang-mode’":


# Used to work, does not anymore, no error reported, thanks Emacs for the
# repeated waste of time...
#
#${emacs} "${target_file}" --batch --eval="(whitespace-cleanup)" -f save-buffer 1>/dev/null 2>&1

#${emacs} "${target_file}" --batch --eval=(add-to-list 'load-path "BASE_DIR/") --eval="(require 'whitespace)" --eval='(whitespace-cleanup)' --eval='(save-buffer 0)' #1>/dev/null 2>&1

#${emacs} "${target_file}" --batch --eval='(load "BASE_DIR/whitespace.el")' --eval='(whitespace-cleanup)' --eval='(save-buffer 0)' #1>/dev/null 2>&1

#${emacs} "${target_file}" --batch --eval='(load user-init-file)' --eval='(whitespace-cleanup)' --eval='(save-buffer 0)'

# Brutal, requires to use our conventions, yet at least is functional:
init_el="${HOME}/.emacs.d/init.el"

if [ ! -f "${init_el}" ]; then

	echo "  Error, no init.el found (no '${init_el}')." 1>&2

	exit 50

fi

${emacs} "${target_file}" --batch --eval="(load-file \"${init_el}\")" --eval='(whitespace-cleanup)' --eval='(save-buffer 0)' 1>/dev/null 2>&1


if [ ! $? -eq 0 ]; then

	echo "  Error, processing of '${target_file}' failed." 1>&2
	exit 20

fi

[ $verbose -eq 1 ] || echo "  + file '${target_file}' cleaned up"

# Possibly created by emacs:
/bin/rm -f "${target_file}~" 2>/dev/null
