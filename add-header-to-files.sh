#!/bin/sh

USAGE="
  Usage: "`basename $0`" <header file> { <file extension> | <file names> }
  Adds text header specified in <header file> at the beginning of all files specified in the command line, or whose extension is <file extension>, found from current directory.
  Example: 
    "`basename $0`" myHeader.txt first.txt second.h third.cc
    "`basename $0`" myHeader.txt .cc
"

echo

# By default will recurse (based on extension):
do_recurse=0

# At least two parameters required:
if [ $# -le 1 ] ; then

	echo "Error, not enough parameters specified. $USAGE" 1>&2
	exit 5
	
fi


header_file="$1"

if [ ! -f "${header_file}" ] ; then

	echo "Error, header file '${header_file}' not found. $USAGE" 1>&2
	exit 10
	
fi

shift 

if [ ! $# -eq 1 ] ; then

	# More than one remaining parameter: we have a list of files.
	do_recurse=1
	target_files="$*"
	
else

	#echo "Remaining parameters: $*"
	
	# Second parameter is either a single file or an extension:
	if [ -f "$1" ] ; then

		# File exists, not an extension, thus this is a list with one element:
		target_files="$1"
		do_recurse=1
		
	else
	
		extension="$1"	
		echo "Will select files whose extension is '$extension' from current directory ("`pwd`")"
		target_files=`find . -name "*${extension}" -a -type f`

		if [ -z "${target_files}" ] ; then

			echo "Error, no target file with extension '${extension}' found. $USAGE" 1>&2
			exit 15

		fi
		
	fi
	
fi



echo "  Adding the header specified in file '${header_file}' at the beginning of following files: 
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

