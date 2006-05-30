#!/bin/bash

# diffDir.sh operates only on the direct entries of a directory.
# See diffTree.sh for a recursive comparison.


USAGE="\nUsage : `basename $0` <first path (main one)> <second path (to be integrated into first one)> [ -v ] [ -a ] [ -h ] : compares thanks to diff all files which are present both in first and second directories, and warns if they are not identical. Warns too if some files are in one directory but not in the other.\n\t The -v option stands for verbose mode, where identical files are notified too.\n\t The -a option stands for automatic diff editing : a merge tool (default : tkdiff) is triggered whenever a difference is detected, and an editor (default : $EDITOR, otherwise nedit) is triggered to modify the corresponding file being on the first path.\n\t The -h option gives this help."


if [ -z "$2" ] ; then
	echo -e "Error, not enough arguments specified. $USAGE" 1>&2
	exit 1
fi

firstDir="$1"
secondDir="$2"

DEFAULT_TEXT="[00;37;40m"
PREFIX_IDEN="     "
PREFIX_DIFF="[00;30;43m---> "
PREFIX_NOEX="[00;37;41m#### "

MERGE_TOOL=`which tkdiff | grep -v ridiculously 2>/dev/null`

if [ -x "$EDITOR" ]; then
	EDITOR_TOOL=$EDITOR
else
	EDITOR_TOOL=`which nedit | grep -v ridiculously 2>/dev/null`
fi

be_verbose=1
be_quiet=1
auto_edit=1


if [ ! -d "$firstDir" ] ; then
	echo -e "Error, first directory specified ($firstDir) does not exist. $USAGE"
	exit 2
fi

if [ ! -d "$secondDir" ] ; then
	echo -e "Error, second directory specified ($secondDir) does not exist. $USAGE"
	exit 3
fi

shift
shift

while [ "$#" -gt "0" ] ; do
	token_eaten=1
	
	if [ "$1" == "-v" ] ; then
		be_verbose=0
		token_eaten=0
	fi

	if [ "$1" == "-q" ] ; then
		be_quiet=0
		token_eaten=0
	fi

	if [ "$1" == "-a" ] ; then
		auto_edit=0
		token_eaten=0
	fi
	
	if [ "$1" == "-h" ] ; then
		echo -e "$USAGE"
		exit
		token_eaten=0
	fi

	if [ "$token_eaten" == "1" ] ; then
		echo "Error, unknown argument ($1)." 1>&2
		exit 4
	fi	
	shift
done

if [ "$auto_edit" == "0" ] ; then
	if [ ! -x "$MERGE_TOOL" ] ; then
		echo "Error, no executable merge tool found ($MERGE_TOOL), automatic diff editing disabled." 1>&2
		auto_edit=1
	fi
	
	if [ ! -x "$EDITOR_TOOL" ] ; then
		echo "Error, no executable editor found ($EDITOR_TOOL), automatic diff editing disabled." 1>&2
		auto_edit=1
	fi
	
	
fi

# To tell a new directory is scanned :
echo


if [ "$be_quiet" == "1" ] ; then
	echo "Comparing files in $firstDir and $secondDir :"
	echo
fi

for f in `/bin/ls $firstDir`; do

	if [ ! -e "$secondDir/$f" ] ; then
		echo "${PREFIX_NOEX}$f is only in $firstDir (not in $secondDir).${DEFAULT_TEXT}"
	else
		if [ ! -d "$firstDir/$f" ] ; then
		
			if diff "$firstDir/$f" "$secondDir/$f" 1>/dev/null 2>&1 ; then
				[ "$be_verbose" == "1" ] || echo "${PREFIX_IDEN}($f identical in the two directories)${DEFAULT_TEXT}"
			else
				echo "${PREFIX_DIFF} $f differs !${DEFAULT_TEXT}"
				if [ "$auto_edit" == "0" ]; then 
					$MERGE_TOOL "$firstDir/$f" "$secondDir/$f" &
					$EDITOR_TOOL "$firstDir/$f"
				fi	
			fi
		else
			if [ ! -d "$secondDir/$f" ] ; then
				echo "${PREFIX_DIFF} $f is a directory in $firstDir and a file in $secondDir !${DEFAULT_TEXT}"
			fi
		fi
	fi	
done

for f in `/bin/ls $secondDir`; do

	if [ ! -e "$firstDir/$f" ] ; then
		echo "${PREFIX_NOEX}$f is only in $secondDir (not in $firstDir).${DEFAULT_TEXT}"
	else
		if [ -d "$secondDir/$f" ] ; then
			if [ ! -d "$firstDir/$f" ] ; then
				echo "${PREFIX_DIFF} $f is a file in $firstDir and a directory in $secondDir !${DEFAULT_TEXT}"
			fi
		fi
	fi
done

