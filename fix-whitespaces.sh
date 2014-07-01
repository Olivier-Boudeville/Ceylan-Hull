#!/bin/sh

USAGE="Usage:"$(basename $0)" A_FILE: fixes whitespace problems into specified file."


target_file="$1"

if [ ! $# -eq 1 ] ; then

	echo "  Error, exactly one parameter needed." 1>&2
	echo "$USAGE" 1>&2

	exit 5

fi



if [ ! -f "$target_file" ] ; then

	echo "  Error, file '$target_file' not found." 1>&2
	exit 10

fi


EMACS=$(which emacs 2>/dev/null)

if [ ! -x "$EMACS" ] ; then

	echo "  Error, emacs not found." 1>&2
	exit 15

fi

$EMACS "$target_file" --batch --eval="(whitespace-cleanup)" -f save-buffer 1>/dev/null 2>&1

if [ ! $? -eq 0 ] ; then

	echo "  Error, processing of '$target_file' failed." 1>&2
	exit 20

fi

echo "  + file '$target_file' cleaned up"

# Created by emacs:
/bin/rm -f "${target_file}~" 2>/dev/null
