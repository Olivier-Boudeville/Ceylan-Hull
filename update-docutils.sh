#!/bin/sh

# Note: docutils has been finally preferred to txrstags.

USAGE="Usage : `basename $0` [ --pdf | <path to CSS file to be used, ex: common/css/XXX.css> ]

Updates generated files from more recent docutils files (*.rst).
If '--pdf' is specified, a PDF will be created, otherwise HTML files will be generated, using any specified CSS file. 
"


# Using makefiles for that was far too tedious.
# Meant to be run from 'trunk/src/doc'.
echo "Updating docutils files from web directory..."


DOCUTILS_COMMON_OPT="--no-generator --time --no-source-link --quiet --tab-width=4"

DOCUTILS_HTML_OPT="${DOCUTILS_COMMON_OPT} --cloak-email-addresses --link-stylesheet"

DOCUTILS_PDF_OPT="${DOCUTILS_COMMON_OPT}"


# By default, generate HTML and not PDF:
do_generate_html=0
do_generate_pdf=1


DOCUTILS_OPT="${DOCUTILS_HTML_OPT}"

DOCUTILS_HTML=`which rst2html 2>/dev/null`


if [ -n "$1" ] ; then

	if [ "$1" = "--pdf" ] ; then
		do_generate_html=1
		do_generate_pdf=0

	else
	
		CSS_FILE="$1"
		# echo "Using CSS file ${CSS_FILE}."
	
		DOCUTILS_HTML_OPT="${DOCUTILS_HTML_OPT} --stylesheet-path=${CSS_FILE} "
	fi

fi


if [ $do_generate_html -eq 0 ] ; then

	DOCUTILS_HTML=`which rst2html 2>/dev/null`
	if [ -z "${DOCUTILS_HTML}" ] ; then
		
		echo "Error, unable to find an executable tool to convert docutils files to HTML (rst2html)." 1>&2
		exit 10
			
	fi

fi

if [ $do_generate_pdf -eq 0 ] ; then

	DOCUTILS_LATEX=`which rst2latex 2>/dev/null`
	if [ -z "${DOCUTILS_LATEX}" ] ; then
		
		echo "Error, unable to find an executable tool to convert docutils files to LateX (rst2latex)." 1>&2
		exit 11
			
	fi
	
	LATEX_TO_PDF=`which pdflatex 2>/dev/null`
	if [ -z "${LATEX_TO_PDF}" ] ; then
		
		echo "Error, unable to find an executable tool to convert LateX files to PDF (pdflatex)." 1>&2
		exit 12
			
	fi

fi




manage_rst_to_html()
# $1: name of the .rst file to convert to HTML.
{

	SOURCE=$1
	TARGET=$2
	
	echo "----> rebuilding HTML target $TARGET from more recent source"

	start=$SOURCE
	back_path=""
	
	while [ "$start" != "." ] ; do
		start=`dirname $start`
		back_path="../$back_path"
		#echo "new start = $start"
	done
	
	# Useless with docutils: back_path=`dirname "$back_path"`/$CSS_FILE
	#echo "Back path to CSS file is $back_path"
	
	#${DOCUTILS_HTML} ${DOCUTILS_HTML_OPT} --stylesheet-path=$CSS_FILE $SOURCE $TARGET

	${DOCUTILS_HTML} $SOURCE $TARGET
	if [ ! $? -eq 0 ] ; then
		echo "Error, HTML generation failed for $SOURCE." 1>&2
		exit 5
	fi	
		
	
}



manage_rst_to_pdf()
# $1: name of the .rst file to convert to PDF.
{

	SOURCE=$1
	TARGET=$2
	
	echo "----> rebuilding PDF target corresponding to more recent source $SOURCE"

	TEX_FILE=`echo $SOURCE|sed 's|.rst$|.tex|1'`
	
	${DOCUTILS_LATEX} ${DOCUTILS_PDF_OPT} $SOURCE $TEX_FILE
	if [ ! $? -eq 0 ] ; then
		echo "Error, LateX generation failed for $SOURCE." 1>&2
		exit 6
	fi
		
	# Run thrice on purpose, to fix links:
	${LATEX_TO_PDF} ${TEX_FILE}
	${LATEX_TO_PDF} ${TEX_FILE}
	${LATEX_TO_PDF} ${TEX_FILE}
	if [ ! $? -eq 0 ] ; then
		echo "Error, PDF generation failed for $SOURCE." 1>&2
		exit 7
	fi
	
}
	
cd web
RST_FILES=`find . -name '*.rst' -a -type f`
#echo $RST_FILES



for f in ${RST_FILES}; do

	echo " + checking $f"
	
	
	if [ ${do_generate_html} -eq 0 ] ; then
	
		TARGET_HTML_FILE=`echo $f|sed 's|.rst$|.html|1'`
		#echo "TARGET_HTML_FILE = $TARGET_HTML_FILE"
	
		# If target does not exist or if source is newer, rebuilds:
		if [ ! -f "${TARGET_HTML_FILE}" -o "$f" -nt "${TARGET_HTML_FILE}" ] ; then
			manage_rst_to_html $f ${TARGET_HTML_FILE}
		fi
		
	fi
	
	
	if [ ${do_generate_pdf} -eq 0 ] ; then
	
		TARGET_PDF_FILE=`echo $f|sed 's|.rst$|.pdf|1'`
		#echo "TARGET_PDF_FILE = $TARGET_PDF_FILE"
	
		# If target does not exist or if source is newer, rebuilds:
		if [ ! -f "${TARGET_PDF_FILE}" -o "$f" -nt "${TARGET_PDF_FILE}" ] ; then
			manage_rst_to_pdf $f ${TARGET_PDF_FILE}
		fi
		
	fi
	
	
done

echo "...docutils files managed."
