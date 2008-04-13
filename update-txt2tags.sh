#!/bin/sh

USAGE="Usage : `basename $0` <path to CSS file to be used, ex: web/common/css/XXX.css>

Updates html files from more recent txt2tags files (*.t2t).
"

# Using makefiles for that was far too tedious.
# Meant to be run from 'trunk/src/doc'.
echo "Updating html files from web directory thanks to txt2tags..."

CSS_FILE="$1"
# echo "Using CSS file ${CSS_FILE}."

# Not kept: --enum-title
TXT2TAGS_OPT="--target=html --encoding=iso-8859-1 --css-sugar --mask-email --toc  --no-rc"


TXT2TAGS=`which txt2tags 2>/dev/null`


manage_t2t()
# $1: name of the .t2t file to manage
{

	SOURCE=$1
	
	echo "----> rebuilding html target from more recent source $SOURCE"
	start=$SOURCE
	back_path=""
	
	while [ "$start" != "." ] ; do
		start=`dirname $start`
		back_path="../$back_path"
		#echo "new start = $start"
	done
	
	back_path=`dirname "$back_path"`/$CSS_FILE
	#echo "Back path to CSS file is $back_path"
	
	${TXT2TAGS} ${TXT2TAGS_OPT} --style=${back_path} $SOURCE
	if [ ! "$?" -eq 0 ] ; then
		echo "Error, txt2tags failed for $SOURCE." 1>&2
		exit 6
	fi	
	
}


if [ ! -x "${TXT2TAGS}" ] ; then
	echo "Error, no txt2tags executable found." 1>&2
	exit 5
fi
	

T2T_FILES=`find web -name '*.t2t' -a -type f`
#echo $T2T_FILES



for f in ${T2T_FILES}; do

	echo " + checking $f"
	TARGET_FILE=`echo $f|sed 's|.t2t$|.html|1'`
	#echo "TARGET_FILE = $TARGET_FILE"
	
	# If target does not exist or if source is newer, rebuilds:
	if [ ! -f "${TARGET_FILE}" -o "$f" -nt "${TARGET_FILE}" ] ; then
		manage_t2t $f
	fi
	
	
done

echo "...txt2tags files managed."
