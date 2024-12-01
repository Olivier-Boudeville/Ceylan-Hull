#!/bin/sh

usage="Usage: $(basename $0) [-h|--help] [-r|--rst] PATTERN: locates the files whose name corresponds to the specified pattern, among the filesystem elements that are routinely scanned; returns only existing files, with the newly-modified ones listed first.

The -r / --rst option allows selecting only RST files (i.e. bearing the '.rst' extension).

We recommend defining an alias in one's shell initialisation, like: \"alias lo='locate.sh'\".
"

# Our version of locate; used to be a shell function.


if [ $# -eq 0 ]; then

	echo "  Error, no argument specified.
${usage}" 1>&2

	exit 5

fi

if [ "$1" = "-h" ] || [ "$1" = "--help" ]; then

	echo "${usage}"

	exit

fi


select_only_rst=1

if [ "$1" = "-r" ] || [ "$1" = "--rst" ]; then

	#echo "(selecting only RST files)"

	select_only_rst=0

	shift

fi


if [ ! $# -eq 1 ]; then

	echo "  Error, at least one extra argument specified.
${usage}" 1>&2

	exit 8

fi


locate="$(which locate 2>/dev/null)"

if [ ! -x "${locate}" ]; then

		echo "  Error, no 'locate' executable available." 1>&2

	exit 10

fi

excluded_patterns="myriad-backups"

if [ -z "${PAGER_NAME}" ]; then

	# Our shell defaults imply 'less', with relevant options:
	PAGER_NAME="/usr/bin/more"

fi

#"${locate}" "$1" | grep -v "${excluded_patterns}" | /bin/ls -l --color | ${PAGER_NAME} ${PAGER_PRESERVE_COLORS}

#(for e in $(locate --existing "$1" | grep -v "${excluded_patterns}"); do /bin/ls -1 -s --human-readable --color "$e" 2>&1; done) | ${PAGER_NAME} ${PAGER_PRESERVE_COLORS}

# Prompt included in pager; '--null' for proper xargs interpretation; not using
# directly locate --null as we want to use (line-based) grep beforehand, so
# newlines are transformed in null characters afterwards (thanks to "tr '\n'
# '\0"); '2>/dev/null' useful if the pager interrupts ls):
#
if [ $select_only_rst -eq 0 ]; then

	(echo "  Trying to locate '$1' (excluding the '${excluded_patterns}' pattern, selecting only RST files, and listing newly-modified files first):"; "${locate}" --existing "$1" | grep '.rst$' | grep -v ${excluded_patterns} | tr '\n' '\0' | xargs --null /bin/ls --directory --sort=time -1 -s --human-readable --color 2>/dev/null) | "${PAGER_NAME}" ${PAGER_PRESERVE_COLORS}

else

	(echo "  Trying to locate '$1' (excluding the '${excluded_patterns}' pattern, and listing newly-modified files first):"; "${locate}" --existing "$1" | grep -v ${excluded_patterns} | tr '\n' '\0' | xargs --null /bin/ls --directory --sort=time -1 -s --human-readable --color 2>/dev/null) | "${PAGER_NAME}" ${PAGER_PRESERVE_COLORS}

fi
