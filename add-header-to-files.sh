#!/bin/sh

USAGE="
  Usage: "`basename $0`" HEADER_FILE EXTENSION
  Adds text header specified in HEADER_FILE at the beginning of all files whose extension is EXTENSION found from current directory.
  Example: "`basename $0`" myHeader.txt .cc
"

echo

if [ ! $# -eq 2 ] ; then

	echo "Error, two parameters expected. $USAGE" 1>&2
	exit 5
	
fi


header_file="$1"

if [ ! -f "${header_file}" ] ; then

	echo "Error, file '${header_file}' not found. $USAGE" 1>&2
	exit 10
	
fi


extension="$2"


target_files=`find . -name "*${extension}" -a -type f`

if [ -z "${target_files}" ] ; then

	echo "Error, no target file with extension '${extension}' found. $USAGE" 1>&2
	exit 15

fi


echo "  Adding header specified in file '${header_file}' at the beginning of all files whose extension is '${extension}' found from current directory ("`pwd`")."

echo "Target files would be: 
${target_files}"

tmp_file=".add-header-to-files.tmp"

mv="/bin/mv -f"
rm="/bin/rm -f"


unset value
read -p "Let's proceed with substitution? (y/n) [n]" value
if [ "$value" = "y" ]; then

	echo "Adding header..."
	for f in ${target_files} ; do
	
		echo "  + processing $f"
		${mv} "$f" "${tmp_file}"
		cat "${header_file}" "${tmp_file}" > "$f"
		${rm} "${tmp_file}"
	
	done
	echo "... finished"
	
else

	echo "Cancelled." 1>&2
	exit 1
	
fi

