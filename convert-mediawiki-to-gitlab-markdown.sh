#!/bin/sh


usage="Usage: $(basename $0) MEDIAWIKI_SOURCE_FILE: converts specified Mediawiki source file (ex: 'foobar.mediawiki') in a GitLab Markdown counterpart file (ex: 'foobar.gitlabmd')."


pandoc="$(which pandoc)"

if [ ! -x "${pandoc}" ]; then

	echo "  Error, no pandoc tool found." 1>&2
	exit 5

fi


if [ ! $# -eq 1 ]; then

	echo "  Error, exactly one parameter expected.
${usage}" 1>&2
	exit 10

fi


source_file="$1"

if [ ! -f "${source_file}" ]; then

	echo "  Error, specified source file ('${source_file}') not found." 1>&2
	exit 15

fi


# Any pre-existing mediawiki file will be silently overwritten:
target_file=$(echo "${source_file}" | sed 's|\.mediawiki$|.gitlabmd|1')

#echo "target_file = ${target_file}"

export LANG=fr_FR.utf8


# At least currently Pandoc does not support directly GitLab's markdown
# (cf. https://pandoc.org/MANUAL.html#options). We go for the closest: GitHub
# one, i.e. gfm.
#
echo " - converting '${source_file}' to '${target_file}'"
${pandoc} --from=mediawiki --to=gfm "${source_file}" -o "${target_file}"

if [ ! $? -eq 0 ]; then

	echo "  Conversion of '${source_file}' failed." 1>&2

	exit 50

fi
