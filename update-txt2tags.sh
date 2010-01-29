#!/bin/sh

# Note: docutils has been finally preferred to txt2tags.
# See update-docutils.sh.


USAGE="Usage: `basename $0` [ --pdf | <path to CSS file to be used, ex: common/css/XXX.css> ]

Updates generated files from more recent txt2tags files (*.t2t).
If '--pdf' is specified, a PDF will be created, otherwise HTML files will be generated, using any specified CSS file. 
"


# Using makefiles for that was far too tedious.
# Meant to be run from 'trunk/src/doc'.
echo "Updating txt2tags files from web directory..."

TXT2TAGS_HTML_OPT="--target=html --encoding=iso-8859-1 --css-sugar --mask-email --toc --no-rc"

TXT2TAGS_PDF_OPT="--target=tex --encoding=iso-8859-1 --enum-title --toc --no-rc"


# By default, generate HTML and not PDF:
do_generate_html=0
do_generate_pdf=1


TXT2TAGS_OPT="${TXT2TAGS_HTML_OPT}"

if [ -n "$1" ] ; then

	if [ "$1" = "--pdf" ] ; then
		do_generate_pdf=0
		do_generate_html=1
		TXT2TAGS_OPT=${TXT2TAGS_PDF_OPT}
		
	else
	
		CSS_FILE="$1"
		# echo "Using CSS file ${CSS_FILE}."
	
	fi

fi

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
	
	
cd web
T2T_FILES=`find . -name '*.t2t' -a -type f`
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
