#!/bin/sh

# Note: docutils has been finally preferred to txt2tags.

USAGE="Usage : `basename $0` <target rst file> [ --pdf | --all | <path to CSS file to be used, ex: common/css/XXX.css> ]

Updates specified file from more recent docutils source (*.rst).
If '--pdf' is specified, a PDF will be created, if '--all' is specified, all output formats (i.e. HTML and PDF) will be created, otherwise HTML files only will be generated, using any specified CSS file. 
"


# Left out: --warnings=rst-warnings.txt --traceback --verbose  --debug
# Can be removed for debugging: --quiet
DOCUTILS_COMMON_OPT="--report=error --no-generator --date --no-source-link --tab-width=4 --strip-comments"

DOCUTILS_HTML_OPT="${DOCUTILS_COMMON_OPT} --cloak-email-addresses --link-stylesheet --no-section-numbering"

DOCUTILS_PDF_OPT="${DOCUTILS_COMMON_OPT}"

LATEX_TO_PDF_OPT="-interaction nonstopmode"

BEGIN_MARKER="---->"

# By default, generate HTML and not PDF:
do_generate_html=0
do_generate_pdf=1


DOCUTILS_OPT="${DOCUTILS_HTML_OPT}"

DOCUTILS_HTML=`which rst2html 2>/dev/null`


if [ -z "$1" ] ; then
	echo "Error: no parameter given. $USAGE" 1>&2
	exit 1
fi

RST_FILE=$1

if [ -e "${RST_FILE}" ] ; then

	shift 
	
	if [ "$1" = "--pdf" ] ; then
	
		do_generate_html=1
		do_generate_pdf=0
		shift
		
	elif [ "$1" = "--all" ] ; then
	
		do_generate_html=0
		do_generate_pdf=0
		shift
		
		CSS_FILE="$1"
		
		if [ -n "${CSS_FILE}" ] ; then
			# echo "Using CSS file ${CSS_FILE}."
			CSS_OPT="--stylesheet-path=${CSS_FILE}"
		fi	
			
		DOCUTILS_HTML_OPT="${DOCUTILS_HTML_OPT} ${CSS_OPT}"
		
	else
	
		if [ -n "${CSS_FILE}" ] ; then
			# echo "Using CSS file ${CSS_FILE}."
			CSS_OPT="--stylesheet-path=${CSS_FILE}"
		fi	
			
		DOCUTILS_HTML_OPT="${DOCUTILS_HTML_OPT} ${CSS_OPT}"

	fi

else

	echo "${BEGIN_MARKER} Error: file $1 not found. $USAGE" 1>&2
	exit 2

fi


if [ $do_generate_html -eq 0 ] ; then

	DOCUTILS_HTML=`which rst2html 2>/dev/null`
	if [ -z "${DOCUTILS_HTML}" ] ; then
		
		echo "${BEGIN_MARKER} Error: unable to find an executable tool to convert docutils files to HTML (rst2html)." 1>&2
		exit 10
			
	fi

fi

if [ $do_generate_pdf -eq 0 ] ; then

	DOCUTILS_LATEX=`which rst2latex 2>/dev/null`
	if [ -z "${DOCUTILS_LATEX}" ] ; then
		
		echo "${BEGIN_MARKER} Error: unable to find an executable tool to convert docutils files to LateX (rst2latex)." 1>&2
		exit 11
			
	fi
	
	LATEX_TO_PDF=`which pdflatex 2>/dev/null`
	if [ -z "${LATEX_TO_PDF}" ] ; then
		
		echo "${BEGIN_MARKER} Error: unable to find an executable tool to convert LateX files to PDF (pdflatex)." 1>&2
		exit 12
			
	fi

fi




manage_rst_to_html()
# $1: name of the .rst file to convert to HTML.
{

	SOURCE=$1
	TARGET=$2
	
	echo "${BEGIN_MARKER} building HTML target $TARGET from source"
	
	#${DOCUTILS_HTML} $SOURCE $TARGET

	echo ${DOCUTILS_HTML} ${DOCUTILS_HTML_OPT} --stylesheet-path=$CSS_FILE $SOURCE $TARGET

	if [ ! $? -eq 0 ] ; then
		echo "${BEGIN_MARKER} Error: HTML generation with ${DOCUTILS_HTML} failed for $SOURCE." 1>&2
		exit 5
	fi	
		
	
}



manage_rst_to_pdf()
# $1: name of the .rst file to convert to PDF.
{

	SOURCE=$1
	TARGET=$2
	
	echo "${BEGIN_MARKER} building PDF target corresponding to source $SOURCE"

	TEX_FILE=`echo $SOURCE|sed 's|.rst$|.tex|1'`
	
	#echo "Docutils command: ${DOCUTILS_LATEX} ${DOCUTILS_PDF_OPT} $SOURCE $TEX_FILE
	
	${DOCUTILS_LATEX} ${DOCUTILS_PDF_OPT} $SOURCE $TEX_FILE
	RES=$?
	
	if [ ! ${RES} -eq 0 ] ; then
	
		if [ ${RES} -eq 1 ] ; then
			echo "${BEGIN_MARKER} Warning: LateX generation returned code 1 for $SOURCE." 1>&2
		else
			echo "${BEGIN_MARKER} Error: LateX generation failed for $SOURCE." 1>&2
			exit 6
		fi
			
	fi
	
		
	# Run thrice on purpose, to fix links:
	echo "LateX command: ${LATEX_TO_PDF} ${LATEX_TO_PDF_OPT} ${TEX_FILE}"
	
	${LATEX_TO_PDF} ${LATEX_TO_PDF_OPT} ${TEX_FILE} && \
	${LATEX_TO_PDF} ${LATEX_TO_PDF_OPT} ${TEX_FILE} && \
	${LATEX_TO_PDF} ${LATEX_TO_PDF_OPT} ${TEX_FILE}
	
	RES=$?
	
	if [ ! $RES -eq 0 ] ; then

		#if [ ${RES} -eq 1 ] ; then
		#	echo "${BEGIN_MARKER} Warning: PDF generation returned code 1 for $SOURCE." 1>&2
		#else
		#	echo "${BEGIN_MARKER} Error: PDF generation failed for $SOURCE (error code: $RES)." 1>&2
		#	exit 7
		#fi
		
		if [ ${RES} -eq 0 ] ; then
			echo "${BEGIN_MARKER}PDF generation succeeded for $SOURCE." 1>&2
		else
			echo "${BEGIN_MARKER} Error: PDF generation failed for $SOURCE (error code: $RES)." 1>&2
			exit 7
		fi

	fi
	
}
	
	
	

if [ ${do_generate_html} -eq 0 ] ; then

	TARGET_HTML_FILE=`echo $RST_FILE|sed 's|.rst$|.html|1'`
	#echo "TARGET_HTML_FILE = $TARGET_HTML_FILE"

	manage_rst_to_html $RST_FILE ${TARGET_HTML_FILE}
	
fi


if [ ${do_generate_pdf} -eq 0 ] ; then

	TARGET_PDF_FILE=`echo $RST_FILE|sed 's|.rst$|.pdf|1'`
	#echo "TARGET_PDF_FILE = $TARGET_PDF_FILE"
		
	# PDF generator will not find includes (ex: images) if not already
	# in target dir:
	CURRENT_DIR=`pwd`
	TARGET_DIR=`dirname ${TARGET_PDF_FILE}`
	
	SOURCE_FILE=`basename ${RST_FILE}`
	TARGET_FILE=`basename ${TARGET_PDF_FILE}`
	
	cd ${TARGET_DIR}
	manage_rst_to_pdf ${SOURCE_FILE} ${TARGET_FILE}
	cd ${CURRENT_DIR}	
	
fi

