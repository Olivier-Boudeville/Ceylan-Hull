#!/bin/sh

default_base_output_base_filename="latex-formula"

usage="Usage: $(basename $0) [-f|--format FMT] [-b|--border] [-d|--display] LATEX_FORMULA_STR [OUTPUT_IMG_FILE_PATH]
Generates an image representing the specified LaTeX formula, possibly with a suitable border.
If no output image file path is specified, will default to a '${default_base_output_base_filename}' base file name, complemented with the extension of the selected image file format, written in the current directory.

Options:
  -f or --format FMT: generates an image file according to the specified format, among 'svg' (the default) and 'png'
  -b or --border: adds a border to the image (implies the PNG format, and a solid, white background, an extra white border itself bordered with black)
  -d or --display: displays the image once generated

The SVG output format is the most recommended one: unlimited precision, transparency.
The PNG format is mostly a fallback one.

Examples:
 $(basename $0) '(a+b)^2=a^2+b^2+2ab'
 $(basename $0) '\gamma(v) = \frac{1}{\sqrt{1-\frac{v^2}{c^2}}}' lorentz-factor.svg
 $(basename $0) --display 'Tf(r) = \sqrt{1-2.\frac{G.M}{r.c^2}}'
 $(basename $0) -f png '\mathit{ws}_i\cap\mathit{ws}_j\neq\emptyset' my-formula.png
"

# Possible inspirations:
#  - tex2svg:
#   * https://github.com/yannikschaelte/tex2svg
#   * https://github.com/mathjax/MathJax-demos-node/blob/master/component/tex2svg
#  - tex2png


# Defaults:
format="svg"
dpi=500
border=1
do_display=1


# Process optional arguments first:

token_eaten=0

while [ $token_eaten -eq 0 ]; do

	token_eaten=1

	if [ "$1" = "-h" ] || [ "$1" = "--help" ]; then
		echo "${usage}"
		exit
	fi

	if [ "$1" = "-f" ] || [ "$1" = "--format" ]; then

		token_eaten=0

		shift
		fmt="$1"
		#echo "Specified format: '${fmt}'."

		if [ -z "${fmt}" ]; then

			echo "  Error, no image file format specified.
${usage}" 1>&2
			exit 5

		fi

		case "${fmt}" in

			"svg")
				format="svg"
				;;

			"png")
				format="png"
				;;

			*)
				echo "  Error, invalid format ('${fmt}')." 1>&2
				exit 10

		esac
		shift

	fi

	if [ "$1" = "-b" ] || [ "$1" = "--border" ]; then
		shift
		border=0
		token_eaten=0
	fi

	if [ "$1" = "-d" ] || [ "$1" = "--display" ]; then
		shift
		do_display=0
		token_eaten=0
	fi

done


# Now mandatory arguments:

user_formula="$1"

if [ -z "${user_formula}" ]; then

	echo "  Error, no LaTeX formula specified.
${usage}" 1>&2

	exit 20

fi

shift

#echo "Selected format: '${format}'."

#echo "User-specified formula: '${user_formula}'."

# Escaping the formula (for backslash and ampersand) does not seem relevant:
#formula=$(echo "${user_formula}" | sed 's|\\|\\\\|g;s|&|\&|g')
formula=$(echo "${user_formula}")

#echo "Final formula: '${formula}'."

output_img_file_path="$1"


#echo "Output image file path: '${output_img_file_path}'."

tmp_dir="$(mktemp -d /tmp/$(basename $0)_XXXXXX)" || exit 2
#echo "Temporary directory: '${tmp_dir}'."

# Do not start filename with a dot (otherwise prepare to manage 'openout_any =
# p'):
#
tmp_file="${tmp_dir}/$(basename $0).tex"
#echo "Temporary file: '${tmp_file}'."

if [ -f "${tmp_file}" ]; then

	echo "(removing a prior '${tmp_file}')"
	/bin/rm -f "${tmp_file}"

fi


latex="$(which latex 2>/dev/null)"

if [ ! -x "${latex}" ]; then

	echo "  Error, no LaTeX executable ('latex') available." 1>&2

	exit 25

fi



if [ $border -eq 0 ]; then

	if [ ! "${format}" = "png" ]; then

		# As would not operate correctly onto SVG:
		echo "Warning: border requested, switching from the ${format} format to the png one." 1>&2
		format="png"

	fi

	magick="$(which magick 2>/dev/null)"

	if [ ! -x "${magick}" ]; then

		echo "  Error, no 'magick' tool available." 1>&2

		exit 32

	fi

fi


# Now 'format' is stable:

if [ -z "${output_img_file_path}" ]; then
	output_img_file_path="${default_base_output_base_filename}.${format}"
fi


case "${format}" in

	"svg")
		dvi2svg="$(which dvisvgm 2>/dev/null)"

		if [ ! -x "${dvi2svg}" ]; then

			echo "  Error, no converter from DVI to SVG ('dvisvgm') available." 1>&2

			exit 30

		fi
		;;

	"png")
		dvi2png="$(which dvipng 2>/dev/null)"

		if [ ! -x "${dvi2png}" ]; then

			echo "  Error, no converter from DVI to PNG ('dvipng') available." 1>&2

			exit 31

		fi
		;;

	*)
		echo "(unexpected format)"
		exit 2
		;;

esac



# Creating the template LaTeX file:

cat >> "${tmp_file}" <<TEX
\documentclass{article}
\usepackage[paperwidth=\maxdimen,paperheight=\maxdimen]{geometry}
\usepackage[utf8]{inputenc}
\usepackage{lmodern}
\usepackage{amssymb}
\usepackage{amsfonts}
\usepackage{amsmath}
\pagestyle{empty}
\begin{document}
\begin{samepage}
\$${formula}\$
\end{samepage}
\end{document}
TEX


#echo "Running LC_ALL=C ${latex} -halt-on-error -output-directory="${tmp_dir}" "${tmp_file}""

# Not taken into account apparently: TEXMFOUTPUT="${tmp_dir}"
if ! LC_ALL=C ${latex} -halt-on-error -output-directory="${tmp_dir}" "${tmp_file}" 1>/dev/null; then

	echo "  Error, the LaTeX processing of the formula failed." 1>&2

	exit 15

fi

# Not expecting a waiting to be needed.

# A DVI file can be viewed with evince for example.

dvi_file="${tmp_dir}/$(basename $0).dvi"

if [ ! -f "${dvi_file}" ]; then

	echo "  Error, the expected DVI file, '${dvi_file}', was not generated." 1>&2

	exit 20

fi


case "${format}" in

	"svg")
		# --no-fonts: draw glyphs by using directly path elements rather than
		# embedding fonts; otherwise may default to very basic and ugly
		# renderings
		#
		# --exact: compute better bounding boxes to avoid faulty clipping

		if ! ${dvi2svg} --no-fonts --exact --tmpdir="${tmp_dir}" --output="${output_img_file_path}" "${dvi_file}" 1>/dev/null 2>&1; then

			echo "  Error, failed to generate the SVG file from the DVI one." 1>&2

			exit 25

		fi
		;;


	"png")

		if ! ${dvi2png} -q -D "${dpi}" -bg transparent -T tight --png -z 9 -o "${output_img_file_path}" "${dvi_file}" 1>/dev/null 2>&1; then
			echo "  Error, failed to generate the PNG file from the DVI one." 1>&2

			exit 26

		fi
		;;


	*)
		echo "(unexpected format)"
		exit 2
		;;

esac

if [ $border -eq 0 ]; then

	#echo "Adding border"

	# First replacing translucency with a solid white background, then adding a
	# white border (margin), then the expected black border:
	#
	"${magick}" "${output_img_file_path}" -background white -alpha remove -alpha off -bordercolor white -border 8 -bordercolor black -border 2 "${output_img_file_path}"

fi

svg_display="inkscape"

# For some reason, eog display is awful:
png_display="gwenview"


if [ ! -f "${output_img_file_path}" ]; then

	echo "  Error, unable to find the generated file (${output_img_file_path})." 1>&2

	exit 30

else

	if [ $do_display -eq 0 ]; then

		echo "File '${output_img_file_path}' is ready; displaying it."

	else

		case "${format}" in

			"svg")
				display="${svg_display}"
			;;

			"png")
				display="${png_display}"
			;;

		esac

		echo "File '${output_img_file_path}' is ready; one may use ${display} to inspect it."

	fi

fi


if [ $do_display -eq 0 ]; then

	case "${format}" in

		"svg")
			display_exec="$(which ${svg_display} 2>/dev/null)"
			if [ ! -x "${display_exec}" ]; then

				echo "  Error, unable to display the generated SVG file: no '${svg_display}' executable found." 1>&2
				exit 50

			fi
			;;

		"png")
			display_exec="$(which ${png_display} 2>/dev/null)"
			if [ ! -x "${display_exec}" ]; then

				echo "  Error, unable to display the generated PNG file: no '${png_display}' executable found." 1>&2
				exit 55

			fi
			;;

		*)
			echo "(unexpected format)"
			exit 2
			;;

	esac

	"${display_exec}" "${output_img_file_path}" 2>/dev/null

fi

#cat "${tmp_file}"
/bin/rm -f "${tmp_file}"
