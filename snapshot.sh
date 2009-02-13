#!/bin/sh

USAGE="
`basename $0`: performs a snapshot (tar.bz2.gpg archive) of specified directory.
  Usage: `basename $0` <directory tree to snapshot>
  Example: `basename $0` osdl"


crypt_name="crypt.sh"

crypt_tool=`which ${crypt_name} 2>/dev/null`


if [ ! -x "$crypt_tool" ] ; then

	echo "Error, no executable crypt tool ($crypt_name) found." 1>&2
	exit 4

fi


if [ ! $# -eq 1 ] ; then

	echo "Error, exactly one parameter expected. $USAGE." 1>&2
	exit 5

fi



target_dir="$1"
  
if [ ! -d "$target_dir" ] ; then

	echo "Error, specified directory ($target_dir) does not exist. $USAGE." 1>&2
	exit 6

fi
  
date=`date "+%Y%m%d"`

archive_name="$date-"`basename $target_dir`"-snapshot.tar.bz2"
#echo "archive_name = $archive_name"

tar cvjf "$archive_name" "$target_dir" 

if [ ! $? -eq 0 ] ; then
	
	echo "Error, archive creation failed." 1>&2
	exit 7
	
fi
	
$crypt_tool "$archive_name" && echo "Snapshot file $archive_name.gpg is ready!"

