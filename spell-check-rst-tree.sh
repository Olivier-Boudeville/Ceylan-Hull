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

echo "Spell checking target RST files from ${target_dir}"

echo "Use shift-F7 to trigger spellchecker..."

checker_bin="gedit"
checker_tool=`which $checker_bin`

if [ ! -x "${checker_tool}" ] ; then

	echo "Error, checker tool ($checker_bin) not found." 1>&2
	exit 10
	
fi


target_files=`find ${target_dir} -name "$searched_pattern"`

for f in ${target_files} ; do

	echo "  - opening $f"
	$checker_tool $f 2>/dev/null 
	
done


echo "...done"


backup_files=`find . -name '*~'`

if [ -n "${backup_files}" ] ; then

	echo "Back-up files are: ${backup_files}."
	
	read -p "Remove following backup files? (y/n) [n] " value
	
	if [ "$value" = "y" ] ; then  
		/bin/rm -f ${backup_files}
		echo "Files removed."
	else
		echo "No file removed."
	fi
	
fi

