#!/bin/sh

USAGE="Usage: "`basename $0`" [-fr|-uk]
  Spellchecks all RST files from current directory."

#echo "$USAGE"

searched_pattern="*.rst"

if [ "$1" = "-fr" ] ; then

	searched_pattern="*-french.rst"

fi


if [ "$1" = "-uk" ] ; then

	searched_pattern="*-english.rst"

fi


target_dir=`pwd`

echo "Spell checking targegt RST files from ${target_dir}"

echo "Use shift-F7 to trigger spellchecker..."

checker_bin="gedit"
checker_tool=`which $checker_bin`

if [ ! -x "${checker_tool}" ] ; then

	echo "Error, checker tool ($checker_bin) not found." 1>&2
	exit 10
	
fi

#language="english"
language="french"


find ${target_dir} -name "$searched_pattern" -exec $checker_tool '{}' 2>/dev/null ';'

echo "...done"

