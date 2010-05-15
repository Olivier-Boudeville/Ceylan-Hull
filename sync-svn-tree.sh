#!/bin/bash

USAGE="Usage: "`basename $0`" <SOURCE_DIR> <TARGET_DIR>:
   
  Synchronizes (updates) target directory (<TARGET_DIR>), which should be fully check-ined beforhand, based on source directory (<SOURCE_DIR>), which will not be modified in any way.

"

#echo "$USAGE"

source_dir="$1"
target_dir="$2"

if [ -z "$source_dir" ] ; then
	
	echo "Error, not enough parameters." 1>&2
	echo $USAGE 1>&2
	exit 5

fi

if [ ! -d "$source_dir" ] ; then
	
	echo "Error, source directory $source_dir does not exist.
$USAGE 1>&2"
	exit 10

fi


if [ -z "$target_dir" ] ; then
	
	echo "Error, not enough parameters." 1>&2
	echo $USAGE 1>&2
	exit 15

fi

if [ ! -d "$target_dir" ] ; then
	
	echo "Error, target directory $target_dir does not exist.
$USAGE 1>&2"
	exit 20

fi

# Retrieves an absolute target directory:
initial_dir=`pwd`
cd $target_dir
full_target_path=`pwd`
cd $initial_dir

#svn status $target_dir

echo "
Updating target directory $target_dir from source directory $source_dir..."

cd $source_dir

# First recreate any lacking directory:
find . -name .svn -prune -o -type d -print -exec /bin/mkdir -p $full_target_path/'{}' ';' 1>/dev/null

res=$?

if [ ! $res -eq 0 ] ; then

	echo "There were errors while recreating directories, stopping." 1>&2
	exit 50
fi

# Then copy the files:
find . -name .svn -prune -o -type f -print -exec /bin/cp '{}' $full_target_path/`basename '{}'` ';' 1>/dev/null

res=$?

if [ $res -eq 0 ] ; then

	echo "Synchronised!"

else

	echo "There were errors while copying files, stopping." 1>&2
	exit 55
fi






