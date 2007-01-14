#!/bin/sh


# diffTree.sh performs a recursive comparison on directory elements.


USAGE="\nUsage : `basename $0` <first path (main one)> <second path (to be integrated into first one)> [ -v ] [ -a ] [ -h ] : compares thanks to diff all files which are present both in first and second trees, and warns if they are not identical. Warns too if some files are in one directory but not in the other.\n\t The -v option stands for verbose mode, where identical files are notified too.\n\t The -q option stands for quiet mode, where only actual differences are displayed, without specifiyng which directories are traversed\n\t The -a option stands for automatic diff editing : a merge tool (default : tkdiff) is triggered whenever a difference is detected, and an editor (default : $EDITOR, otherwise nedit) is triggered to modify the corresponding file being on the first path.\n\t The -h option gives this help."

DEFAULT_TEXT="[00;37;40m"
PREFIX_IDEN="     "
PREFIX_DIFF="[00;30;43m---> "
PREFIX_NOEX="[00;37;41m#### "

DIFF_DIR=`which diffDir.sh | grep -v ridiculously 2>/dev/null`

if [ ! -x "$DIFF_DIR" ] ; then
	echo -e "Error, no diff tool for directories found ($DIFF_DIR). $USAGE" 1>&2
	exit 10
fi


FIND=`which find | grep -v ridiculously 2>/dev/null`

firstDir="$1"
secondDir="$2"

if [ -z "$2" ] ; then
	echo -e "Error, not enough arguments specified. $USAGE" 1>&2
	exit 1
fi

if [ ! -d "$firstDir" ] ; then
	echo -e "Error, first directory specified ($firstDir) does not exist. $USAGE"
	exit 2
fi

if [ ! -d "$secondDir" ] ; then
	echo -e "Error, second directory specified ($secondDir) does not exist. $USAGE"
	exit 3
fi

be_verbose=1
be_quiet=1
auto_edit=1

shift
shift
args_to_propagate="$*"

while [ $# -gt 0 ] ; do
	token_eaten=1
	
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
		echo -e "$USAGE"
		exit
		token_eaten=0
	fi

	if [ $token_eaten -eq 1 ] ; then
		echo "Error, unknown argument ($1)." 1>&2
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

	if [ $be_quiet -eq 1 ] ; then
		echo `basename $0`" examining $firstDir/$d and $secondDir/$d"
	fi
		
	if [ ! -d "$secondDir/$d" ] ; then
		echo "${PREFIX_NOEX}Directory $d is only in $firstDir (not in $secondDir).${DEFAULT_TEXT}"
	else
		$DIFF_DIR $firstDir/$d $secondDir/$d $args_to_propagate
	fi
	
done

# Only thing to check then : there could be directories in second path
# not in first path.
cd $secondDir
DIRS=`$FIND . -type d`
cd $old_path

for d in $DIRS ; do

	if [ ! -d "$firstDir/$d" ] ; then
		echo "${PREFIX_NOEX}Directory $d is only in $secondDir (not in $firstDir).${DEFAULT_TEXT}"
	fi
	
done



