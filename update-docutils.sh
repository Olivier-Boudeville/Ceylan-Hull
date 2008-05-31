#!/bin/sh

# Note: docutils has been finally preferred to txt2tags.

USAGE="Usage : `basename $0` [ --pdf | --all | <path to CSS file to be used, ex: common/css/XXX.css> ]

Updates generated files from more recent docutils files (*.rst).
If '--pdf' is specified, a PDF will be created, if '--all' is specified, all output formats (i.e. HTML and PDF) will be created, otherwise HTML files only will be generated, using any specified CSS file. 
"


# Using makefiles for that was far too tedious.
# Meant to be run from 'trunk/src/doc'.
echo "Updating docutils files from web directory..."

# Left out: --warnings=rst-warnings.txt --traceback --verbose  --debug
DOCUTILS_COMMON_OPT="--report=error --no-generator --date --no-source-link --quiet --tab-width=4 --strip-comments"

DOCUTILS_HTML_OPT="${DOCUTILS_COMMON_OPT} --cloak-email-addresses --link-stylesheet --no-section-numbering"

DOCUTILS_PDF_OPT="${DOCUTILS_COMMON_OPT}"

# Left out: --use-latex-footnotes
LATEX_TO_PDF_OPT="-interaction nonstopmode "


# By default, generate HTML and not PDF:
do_generate_html=0
do_generate_pdf=1


DOCUTILS_OPT="${DOCUTILS_HTML_OPT}"

DOCUTILS_HTML=`which rst2html 2>/dev/null`


if [ -n "$1" ] ; then

	if [ "$1" = "--pdf" ] ; then
	
		do_generate_html=1
		do_generate_pdf=0
		shift
		
	elif [ "$1" = "--all" ] ; then
	
		do_generate_html=0
		do_generate_pdf=0
		shift
		
		CSS_FILE="$1"
		# echo "Using CSS file ${CSS_FILE}."
	
		DOCUTILS_HTML_OPT="${DOCUTILS_HTML_OPT} --stylesheet-path=${CSS_FILE} "
		
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

	#start=$SOURCE
	#back_path=""
	
	#while [ "$start" != "." ] ; do
	#	start=`dirname $start`
	#	back_path="../$back_path"
	#	#echo "new start = $start"
	#done
	
	# Useless with docutils: back_path=`dirname "$back_path"`/$CSS_FILE
	#echo "Back path to CSS file is $back_path"
	# So '--stylesheet-path=$CSS_FILE' has been removed.
	
	#${DOCUTILS_HTML} $SOURCE $TARGET

	${DOCUTILS_HTML} ${DOCUTILS_HTML_OPT} $SOURCE $TARGET

	if [ ! $? -eq 0 ] ; then
		echo "Error, HTML generation with ${DOCUTILS_HTML} failed for $SOURCE." 1>&2
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
	echo "LateX command: ${LATEX_TO_PDF} ${LATEX_TO_PDF_OPT} ${TEX_FILE}"
	${LATEX_TO_PDF} ${LATEX_TO_PDF_OPT} ${TEX_FILE} && \
	${LATEX_TO_PDF} ${LATEX_TO_PDF_OPT} ${TEX_FILE} && \
	${LATEX_TO_PDF} ${LATEX_TO_PDF_OPT} ${TEX_FILE}
	
	if [ ! $? -eq 0 ] ; then
		echo "Error, PDF generation failed for $SOURCE." 1>&2
		exit 7
	fi
	
}
	

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
			
			# PDF generator will not find includes (ex: images) if not already
			# in target dir:
			CURRENT_DIR=`pwd`
			TARGET_DIR=`dirname ${TARGET_PDF_FILE}`
			
			SOURCE_FILE=`basename ${f}`
			TARGET_FILE=`basename ${TARGET_PDF_FILE}`
			
			cd ${TARGET_DIR}
			manage_rst_to_pdf ${SOURCE_FILE} ${TARGET_FILE}
			cd ${CURRENT_DIR}
			
		fi
		
	fi
	
	
done

echo "...docutils files managed."
