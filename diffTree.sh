#!/bin/sh


# diffTree.sh performs a recursive comparison on directory elements.


USAGE="Usage: `basename $0` <first path (main one)> <second path (to be integrated into first one)> [ -v ] [ -q ] [ -a ] [ -h ]: compares thanks to diff all files which are present both in first and second trees, and warns if they are not identical. Warns too if some files are in one directory but not in the other.
   The --svn option stands for SVN (Subversion) mode, where SVN informations are ignored (only focusing on file content)
   The -v option stands for verbose mode, where identical files are notified too.
   The -q option stands for quiet mode, where only actual differences are displayed, without specifiyng which directories are traversed
   The -a option stands for automatic diff editing: a merge tool (default: tkdiff) is triggered whenever a difference is detected, and an editor (default: $EDITOR, otherwise nedit) is triggered to modify the corresponding file being on the first path.
   The -h option gives this help."

DEFAULT_TEXT="[00;37;40m"
PREFIX_IDEN="     "
PREFIX_DIFF="[00;30;43m---> "
PREFIX_NOEX="[00;37;41m#### "

DIFF_DIR=`which diffDir.sh|grep -v ridiculously 2>/dev/null`

if [ ! -x "$DIFF_DIR" ] ; then
	echo "Error, no diff tool for directories found ($DIFF_DIR). $USAGE" 1>&2
	exit 10
fi


FIND=`which find | grep -v ridiculously 2>/dev/null`

firstDir="$1"
secondDir="$2"

if [ -z "$2" ] ; then
	echo "Error, not enough arguments specified. $USAGE" 1>&2
	exit 1
fi


if [ ! -d "$firstDir" ] ; then
	echo "Error, first directory specified ($firstDir) does not exist. $USAGE" 1>&2
	exit 2
fi


if [ ! -d "$secondDir" ] ; then
	echo "Error, second directory specified ($secondDir) does not exist. $USAGE" 1>&2
	exit 3
fi

be_verbose=1
be_quiet=1
auto_edit=1
ignore_svn=1

shift
shift

# -r for recursive:
args_to_propagate="$* -r"

while [ $# -gt 0 ] ; do

	token_eaten=1

	if [ "$1" = "--svn" ] ; then
		ignore_svn=0
		args_to_propagate="$args_to_propagate --svn"
		token_eaten=0
	fi

	if [ "$1" = "-v" ] ; then
		be_verbose=0
		token_eaten=0
	fi

	if [ "$1" = "-q" ] ; then
		be_quiet=0
		token_eaten=0
	fi

	if [ "$1" = "-a" ] ; then
		auto_edit=0
		token_eaten=0
	fi

	if [ "$1" = "-h" ] ; then
		echo "$USAGE"
		exit
		token_eaten=0
	fi

	if [ $token_eaten -eq 1 ] ; then
		echo "Error, unknown argument ($1). $USAGE" 1>&2
		exit 4
	fi
	shift
done


old_path=`pwd`

cd $firstDir
DIRS=`$FIND . -type d`

cd $old_path

#echo "DIRS = $DIRS"

for d in $DIRS ; do

	#echo "DIR = $d, BASE = "`basename $d`

	if [ $ignore_svn -eq 1 ] || [ `basename $d` != ".svn" ] ; then

		if [ $be_quiet -eq 1 ] ; then
			echo `basename $0`" examining $firstDir/$d and $secondDir/$d"
		fi

		if [ ! -d "$secondDir/$d" ] ; then
			echo "${PREFIX_NOEX}Directory $d is only in $firstDir (not in $secondDir).${DEFAULT_TEXT}"
		else
			$DIFF_DIR $firstDir/$d $secondDir/$d $args_to_propagate
		fi

	else

		if [ $be_verbose -eq 0 ] ; then
			echo "($d skipped)"
		fi

	fi

done

# Only thing to check then: there could be directories in second path not in
# first path.
cd $secondDir
DIRS=`$FIND . -type d`
cd $old_path

for d in $DIRS ; do

	if [ ! -d "$firstDir/$d" ] ; then
		echo "${PREFIX_NOEX}Directory $d is only in $secondDir (not in $firstDir).${DEFAULT_TEXT}"
	fi

done
