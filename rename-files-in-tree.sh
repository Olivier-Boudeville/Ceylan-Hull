#!/bin/sh

usage="Usage: $(basename $0) PATTERN REPLACEMENT: renames all files recursively found from current directory by replacing specified PATTERN with specified REPLACEMENT."

if [ ! $# -eq 2 ] ; then

   echo "  Error, exactly two parameters required.
  ${usage}" 1>&2

   exit 5

fi

pattern="$1"
replacement="$2"

# The following will not work as the content within $(...) will be evaluated by
# the shell *before* feeding the result (which is the exact filename found) to
# find and thus mv:
#
# find spec -type -exec mv {} $(echo {} | sed "s|${PATTERN}|${REPLACEMENT}|g'" ';'

# See
# https://serverfault.com/questions/226627/recursively-rename-files-using-find-and-sed:


# Problem: remaining generic would imply replacing the "pattern" and
# "replacement" variables, which would be a quoting nightmare:
#
#find . -type f -exec sh -c 'echo mv "$1" "$(echo "$1" | echo sed "s|${pattern}|${replacement}|g")"' _ '{}' ';'


# So we provide just an example with literal, hardcoded PATTERN (hello) and
# REPLACEMENT (goodbye):
#
# find . -type f -exec sh -c 'mv "$1" "$(echo "$1" | sed "s|hello|goodbye|g")"' _ '{}' ';'

echo "See the source of that script as an example, and adapt it to your liking!"

exit 5
