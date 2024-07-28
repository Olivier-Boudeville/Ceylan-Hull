#!/bin/sh

usage="Usage: $(basename $0) [-h|--help] SOURCE.djvu: converts 'SOURCE.djvu' into 'SOURCE.pdf' (warning: the operation may be long and may produce huger files; on our example, a 23 MB DjVU file resulted in a 760 MB PDF). Does not remove the source file."

if [ "$1" = "-h" ] || [ "$1" = "--help" ]; then
		echo "${usage}"
		exit
fi

# Other direction: 'pdf2djvu -d 350 -v -o target.djvu source.pdf'.
# See also https://fr.wikisource.org/wiki/Aide:Cr%C3%A9er_un_fichier_DjVu/Linux

# At least sometime, produces unusable PDFs (grey rectangles, 'Corrupt JPEG
# data', etc.):
#
#ddjvu="$(which ddjvu 2>/dev/null)"

# Might be awfully longer, but a lot better:
djvups="$(which djvups 2>/dev/null)"

# if [ ! -x "${ddjvu}" ]; then

#	#echo "  Error, no 'ddjvu' executable found. Consider installing the 'djvulibre' package." 1>&2

#	exit 5

# fi


if [ ! -x "${djvups}" ]; then

	echo "  Error, no 'djvups' executable found. Consider installing the 'djvulibre' package." 1>&2

	exit 5

fi


ps2pdf="$(which ps2pdf 2>/dev/null)"

if [ ! -x "${ps2pdf}" ]; then

	echo "  Error, no 'ps2pdf' executable found." 1>&2

	exit 5

fi


if [ -z "$*" ]; then

	echo "  Error, no parameter specified.
${usage}" 1>&2

	exit 15

fi

source_file="$1"

shift

if [ -n "$*" ]; then

	echo "  Error, extra parameters specified ('$*').
${usage}" 1>&2

	exit 15

fi


if [ ! -f "${source_file}" ]; then

	echo "  Error, specified input file ('${source_file}') does not exist." 1>&2

	exit 20

fi

target_file="$(echo ${source_file} | sed 's|\.djvu$|.pdf|1')"

#echo "target_file = ${target_file}"

if [ "${target_file}" = "${source_file}" ]; then

	echo "  Error, invalid source file ('${source_file}').
${usage}" 1>&2

	exit 25

fi

echo "  Converting '${source_file}' to '${target_file}'..."


# Alternatively:

#if ! "${ddjvu}" -format=pdf -quality=85 -verbose "${source_file}" "${target_file}"; then

if ! "${djvups}" "${source_file}" | "${ps2pdf}" - "${target_file}"; then

	echo "  Error, the generation of '${target_file}' failed." 1>&2

	exit 50

else

	echo
	echo "The generation of '${target_file}' succeeded!"

fi
