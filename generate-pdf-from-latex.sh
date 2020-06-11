#!/bin/sh

# As cannot be easily guessed from tex files:
bibliography_opt="--bibliography"
glossary_opt="--glossary"

no_display_opt="--no-display"
verbose_opt="--verbose"


# Defaults:

generate_bibliography=1
generate_glossary=1

display_pdf=0
verbose=1

# Biber preferred:
use_bibtex=1
use_biber=0


usage="Usage: $(basename $0) [${bibliography_opt}] [${glossary_opt}] [${no_display_opt}] [${verbose_opt}] LATEX_FILE

Generates a PDF file from a LateX one, and displays it.

Options:
  ${bibliography_opt}: generates a bibliography
  ${glossary_opt}: generates a glossary
  ${no_display_opt}: disables the displaying of the resulting PDF
  ${verbose_opt}: be verbose

Ex: $(basename $0) my_example.tex"


# Runs (once) pdflatex.
run_pdflatex()
{

	pdflatex_source_file="$1"

	pdflatex_base_path="$2"

	pdflatex_target_file="${pdflatex_base_path}.pdf"

	echo "  - running pdflatex on '${pdflatex_source_file}'"

	${pdflatex} -halt-on-error "${pdflatex_source_file}" 1>/dev/null

	res=$?

	if [ ! $res -eq 0 ]; then

		echo "  Error, pdflatex run failed (exit status: $res).
" 1>&2

		view_log "${pdflatex_base_path}.log"

		exit 50

	fi


	if [ ! -f "${pdflatex_target_file}" ]; then

		echo "  Error, pdflatex did dot generate the expected PDF file (${pdflatex_target_file}), despite reporting a sucess exist status." 1>&2

		exit 50

	fi

}



# Runs bibtex.
run_bibtex()
{

	bibtex_base_path="$1"

	bibtex_aux_file="${bibtex_base_path}.aux"

	if [ ! -f "${bibtex_aux_file}" ]; then

		echo "  Error, no bibtex aux file found ('{bibtex_aux_file}')." 1>&2
		exit 55

	fi

	echo "  - running bibtex on '${bibtex_aux_file}'"
	${bibtex} ${bibtex_aux_file}

	res=$?

	if [ ! $res -eq 0 ]; then

		echo "  Error, bibtex run failed (exit status: $res).
" 1>&2

		view_log "${bibtex_base_path}.blg"

		exit 60

	fi

}


# Runs biber.
run_biber()
{

	biber_base_path="$1"

	biber_bcf_file="${biber_base_path}.bcf"

	if [ ! -f "${biber_bcf_file}" ]; then

		echo "  Error, no biber bcf file found ('${biber_bcf_file}')." 1>&2
		exit 55

	fi

	echo "  - running biber on '${biber_bcf_file}'"
	${biber} ${biber_bcf_file} 1>/dev/null

	res=$?

	if [ ! $res -eq 0 ]; then

		echo "  Error, biber run failed (exit status: $res).
" 1>&2

		view_log "${biber_base_path}.blg"

		exit 60

	fi

}


# Runs makeglossaries.
run_makeglossaries()
{

	makeglossaries_base_path="$1"

	makeglossaries_glg_file="${makeglossaries_base_path}.glg"

	echo "  - running makeglossaries"
	${makeglossaries} ${makeglossaries_base_path} 1>/dev/null

	res=$?

	if [ ! $res -eq 0 ]; then

		echo "  Error, makeglossaries run failed (exit status: $res).
" 1>&2

		view_log "${makeglossaries_base_path}.log"

		exit 70

	fi

}


# Cleans all non-PDF by products of running the LateX-related toolchain.
clean_generated_files()
{

	clean_base_path="$1"

	/bin/rm -f ${clean_base_path}.aux ${clean_base_path}.log ${clean_base_path}.bcf ${clean_base_path}.run.xml ${clean_base_path}.bbl ${clean_base_path}.blg #2>/dev/null

}



# Displays the end of the specified log file.
view_log()
{

	log_file="$1"

	if [ ! -f "${log_file}" ]; then

		echo " Error, no log file found ('${log_file}')." 1>&2
		exit 55

	fi

	line_count=30

	echo "Displaying the last ${line_count} lines of '${log_file}':"

	tail --lines=${line_count} ${log_file}

}



token_eaten=0

while [ $token_eaten -eq 0 ]; do

	#[ $verbose -eq 1 ] || echo "Args: $*"

	token_eaten=1

	if [ "$1" = "${bibliography_opt}" ]; then
		shift
		generate_bibliography=0
		token_eaten=0
	fi

	if [ "$1" = "${glossary_opt}" ]; then
		shift
		generate_glossary=0
		token_eaten=0
	fi

	if [ "$1" = "${no_display_opt}" ]; then
		shift
		display_pdf=1
		token_eaten=0
	fi

	if [ "$1" = "${verbose_opt}" ]; then
		shift
		verbose=0
		token_eaten=0
	fi

	if [ "$1" = "-h" ] || [ "$1" = "--help" ]; then
		echo "${usage}"
		exit
		token_eaten=0
	fi

done

if [ $# -eq 0 ]; then

	echo "  Error, no input LateX source file specified." 1>&2
	echo "${usage}" 1>&2
	exit 5

fi

if [ ! $# -eq 1 ]; then

	echo "  Error, expecting a single argument for the input LateX source file, yet got '$*'." 1>&2
	echo "${usage}" 1>&2
	exit 6

fi

source_file="$1"
#echo "source_file = ${source_file}"


pdflatex=$(which pdflatex 2>/dev/null)

if [ ! -x "${pdflatex}" ]; then

	echo "  Error, no PDF generation tool (pdflatex) found." 1>&2
	exit 10

fi


if [ $generate_bibliography -eq 0 ]; then

	if [ $use_bibtex -eq 0 ]; then

		bibtex=$(which bibtex 2>/dev/null)

		if [ ! -x "${bibtex}" ]; then

			echo "  Error, no 'bibtex' bibliography generation tool found." 1>&2
			exit 11

		fi

	elif [ $use_biber -eq 0 ]; then

		biber=$(which biber 2>/dev/null)

		if [ ! -x "${biber}" ]; then

			echo "  Error, no 'biber' bibliography generation tool found." 1>&2
			exit 12

		fi

	fi

fi


if [ $generate_glossary -eq 0 ]; then

	makeglossaries=$(which makeglossaries 2>/dev/null)

	if [ ! -x "${makeglossaries}" ]; then

		echo "  Error, no 'makeglossaries' glossary generation tool found." 1>&2
		exit 13

	fi

fi


if [ $display_pdf -eq 0 ]; then

	pdf_viewer=$(which evince 2>/dev/null)

	if [ ! -x "${pdf_viewer}" ]; then

		echo "  Error, PDF displaying enabled, whereas PDF displayer (evince) not found." 1>&2

		exit 15

	fi

fi



source_file_ext=$(echo "${source_file}" | sed 's|^.*\.||1')

if [ ! "${source_file_ext}" = "tex" ]; then

	echo "  Error, invalid source filename '${source_file}' (expecting *.tex)." 1>&2

	exit 20

fi


if [ ! -f "${source_file}" ]; then

	echo "  Error, source file '${source_file}' not found." 1>&2

	exit 25

fi


# Will be produced in the current directory, not in any directory used here:
path_base_file=$(echo "${source_file}" | sed 's|\.tex$||1' | xargs basename)
#echo "path_base_file = ${path_base_file}"


target_file="${path_base_file}.pdf"
#echo "target_file = ${target_file}"



echo "Generating '${target_file}' from '${source_file}'..."

if [ -f "${target_file}" ]; then

	echo "   (already-existing '${target_file}' removed)"
	/bin/rm -f "${target_file}"

fi

# Yes, running the same command more than once is necessary:

run_pdflatex "${source_file}" "${path_base_file}"

if [ $generate_glossary -eq 0 ]; then

	run_makeglossaries "${path_base_file}"

fi

if [ $generate_bibliography -eq 0 ]; then

	if [ $use_bibtex -eq 0 ]; then
		run_bibtex "${path_base_file}" "${path_base_file}"
	elif [ $use_biber -eq 0 ]; then
		run_biber "${path_base_file}" "${path_base_file}"
	fi

fi



run_pdflatex "${source_file}" "${path_base_file}"

if [ $generate_glossary -eq 0 ]; then

	run_makeglossaries "${path_base_file}"

fi

if [ $generate_bibliography -eq 0 ]; then

	if [ $use_bibtex -eq 0 ]; then
		run_bibtex "${path_base_file}" "${path_base_file}"
	elif [ $use_biber -eq 0 ]; then
		run_biber "${path_base_file}" "${path_base_file}"
	fi

fi

run_pdflatex "${source_file}" "${path_base_file}"



echo "Generation of '${target_file}' succeeded!"

if [ $display_pdf -eq 0 ]; then

	echo "Displaying '${target_file}'..."
	${pdf_viewer} "${target_file}" 1>/dev/null 2>&1

	if [ ! $? -eq 0 ]; then

		echo "  Error, displaying of '${target_file}' failed." 1>&2

		exit 100

	fi

fi

clean_generated_files "${path_base_file}"
