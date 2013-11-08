#!/bin/sh

# diffDir.sh operates only on the direct entries of a directory.
# See diffTree.sh for a recursive comparison.


USAGE="
Usage: `basename $0` <first path (main one)> <second path (to be integrated into first one)> [--svn] [ -v ] [ -a ] [ -h ]: compares thanks to diff all files which are present both in first and second directories, and warns if they are not identical. Warns too if some files are in one directory but not in the other.
   The --svn option stands for SVN (Subversion) mode, where SVN informations are ignored (only focusing on file content)
   The -v option stands for verbose mode, where identical files are notified too.
   The -s option stands for short mode, shorter messages are output.
   The -a option stands for automatic diff editing: a merge tool (default: tkdiff) is triggered whenever a difference is detected, and an editor (default: $EDITOR, otherwise nedit) is triggered to modify the corresponding file being on the first path.
   The -h option gives this help."


if [ -z "$2" ] ; then
	echo "Error, not enough arguments specified. $USAGE" 1>&2
	exit 1
fi

firstDir="$1"
secondDir="$2"

DEFAULT_TEXT="[00;37;40m"
PREFIX_IDEN="     "
PREFIX_DIFF="[00;30;43m---> "
PREFIX_NOEX="[00;37;41m#### "

MERGE_TOOL=`which tkdiff|grep -v ridiculously 2>/dev/null`

if [ -x "$EDITOR" ]; then
	EDITOR_TOOL=$EDITOR
else
	EDITOR_TOOL=`which nedit|grep -v ridiculously 2>/dev/null`
fi

be_verbose=1
be_quiet=1
auto_edit=1
ignore_svn=1
called_as_recursive=1
shorter_messages=1


if [ ! -d "$firstDir" ] ; then
	echo "Error, first directory specified ($firstDir) does not exist. $USAGE" 1>&2
	exit 2
fi

if [ ! -d "$secondDir" ] ; then
	echo "Error, second directory specified ($secondDir) does not exist. $USAGE" 1>&2
	exit 3
fi

shift
shift

while [ $# -gt 0 ] ; do
	token_eaten=1

	if [ "$1" = "--svn" ] ; then
		ignore_svn=0
		token_eaten=0
	fi

	if [ "$1" = "-v" ] ; then
		be_verbose=0
		token_eaten=0
	fi
	if [ "$1" = "-s" ] ; then
		shorter_messages=0
		token_eaten=0
	fi

	if [ "$1" = "-r" ] ; then
		# Less repetitive outputs if called recursively:
		# (see diffTree.sh)
		called_as_recursive=0
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
		echo "Error, unknown argument ($1)." 1>&2
		exit 4
	fi
	shift

done



if [ $auto_edit -eq 0 ] ; then

	if [ ! -x "$MERGE_TOOL" ] ; then
		echo "Error, no executable merge tool found ($MERGE_TOOL), automatic diff editing disabled." 1>&2
		auto_edit=1
	fi

	if [ ! -x "$EDITOR_TOOL" ] ; then
		echo "Error, no executable editor found ($EDITOR_TOOL), automatic diff editing disabled." 1>&2
		auto_edit=1
	fi


fi

 
# To tell a new directory is scanned:

if [ $be_verbose -eq 0 ] ; then

    # Preferably disabled, as otherwise inserts a blank line:
	echo ${DEFAULT_TEXT}

fi


if [ $be_quiet -eq 1 ] ; then
	echo "Comparing files in $firstDir and $secondDir:"
	echo
fi


for f in `/bin/ls $firstDir`; do

	if [ $ignore_svn -eq 1 ] || [ `basename $f` != ".svn" ] ; then

		if [ ! -e "$secondDir/$f" ] ; then
			
			if [ $shorter_messages -eq 0 ] ; then
				echo "${PREFIX_NOEX}'$f' only in FIRST.${DEFAULT_TEXT}"
			else
			echo "${PREFIX_NOEX}'$f' is only in first directory ($firstDir), i.e. not in $secondDir.${DEFAULT_TEXT}"
			
			fi
			
	else
			
			if [ ! -d "$firstDir/$f" ] ; then
				
				if diff "$firstDir/$f" "$secondDir/$f" 1>/dev/null 2>&1 ; then
					[ $be_verbose -eq 1 ] || echo "${PREFIX_IDEN}('$f' identical in the two directories)${DEFAULT_TEXT}"
				else
					echo "${PREFIX_DIFF} '$f' differs!${DEFAULT_TEXT}"
					if [ $auto_edit -eq 0 ]; then
						$MERGE_TOOL "$firstDir/$f" "$secondDir/$f" &
						$EDITOR_TOOL "$firstDir/$f"
					fi
				fi
			else
				if [ ! -d "$secondDir/$f" ] ; then
					echo "${PREFIX_DIFF} '$f' is a directory in '$firstDir' and a file in '$secondDir'!${DEFAULT_TEXT}"
				fi
			fi

		fi

	fi

done


for f in `/bin/ls $secondDir`; do

	if [ ! -e "$firstDir/$f" ] ; then
		if [ $shorter_messages -eq 0 ] ; then
			echo "${PREFIX_NOEX}'$f' only in SECOND.${DEFAULT_TEXT}"
		else
			echo "${PREFIX_NOEX}'$f' is only in second directory ('$secondDir'), i.e. not in '$firstDir'.${DEFAULT_TEXT}"
		fi
	else
		if [ -d "$secondDir/$f" ] ; then
			if [ ! -d "$firstDir/$f" ] ; then
				echo "${PREFIX_DIFF} '$f' is a file in '$firstDir' and a directory in '$secondDir'!${DEFAULT_TEXT}"
			fi
		fi
	fi
done


if [ $called_as_recursive -eq 1 ] ; then
	[ $be_verbose -eq 0 ] || echo "(use the -v option for more information)"
fi
