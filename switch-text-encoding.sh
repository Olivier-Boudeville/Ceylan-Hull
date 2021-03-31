#!/bin/sh

target_encoding="utf-8"

usage="Usage: $(basename $0) A_FILE [TARGET_ENCODING]: converts the specified file so that it gets encoded according to specified, well, encoding.
If no encoding is specified, defaults to ${target_encoding} (Unicode).
Useful for example to properly re-encode pure ASCII or ISO-8859 texts."

target_file="$1"

if [ -n "$2" ]; then

	target_encoding="$2"
	shift

fi

if [ ! $# -eq 1 ]; then

	echo "  Error, incorrect number of parameters specified." 1>&2
	echo "${usage}" 1>&2

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


# C-x C-m c <encoding> RET C-x C-w RET, where <encoding> is for example utf-8:
${emacs} "${target_file}" --batch --eval="(set-buffer-file-coding-system '${target_encoding})" -f save-buffer 1>/dev/null # 2>&1

if [ ! $? -eq 0 ]; then

	echo "  Error, reencoding of 'file ${target_file}' to encoding '${target_encoding}' failed." 1>&2
	exit 20

fi

echo "  + file '${target_file}' reencoded to ${target_encoding}"

# Possibly created by emacs:
/bin/rm -f "${target_file}~" 2>/dev/null
