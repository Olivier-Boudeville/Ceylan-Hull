#!/bin/sh

usage="Usage: $(basename $0) XML_FILE: displays on the terminal a user-friendly view of the specified XML file."


# Stop script on command error and on unset variable:
set -eu

if [ $# -ne 1 ]; then

    echo "${usage}" >&2

    exit 5

fi


xml_file="$(realpath "$1")"

if [ ! -f "${xml_file}" ] && [ ! -L "${xml_file}" ]; then

    echo "  Error, no '${xml_file}' XML file found." >&2

    exit 10

fi


lint_exec="$(which xmllint 2>/dev/null)"

if [ ! -x "${lint_exec}" ]; then

    echo "  Error, no xmllint executable found." >&2

    exit 15

fi


colorize_exec="$(which pygmentize 2>/dev/null)"

if [ ! -x "${colorize_exec}" ]; then

    echo "  Error, no pygmentize executable found." >&2

    exit 20

fi

"${lint_exec}" --format "${xml_file}" | "${colorize_exec}" -l xml
