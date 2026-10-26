#!/bin/sh

# Copyright (C) 2019-2026 Olivier Boudeville
#
# Author: Olivier Boudeville [olivier (dot) boudeville (at) esperide (dot) com]
#
# This file is part of the Ceylan-Hull toolbox (see http://hull.esperide.org).


usage="
Usage: $(basename $0) [-h|--help] [-p|--porcelain] [-f|--force] <an entry path>: renames the specified file or directory to a 'corrected' filesystem entry name, i.e., among (many) other fixes: without spaces or quotes, replaced by '-', with no accentuated characters in it.

Options:

 -p / --porcelain: meant to facilitate the use of this script in other scripts; then, if no error is reported, it outputs only the name of the resulting filesystem entry (whether or not it had to be specifically fixed)

 -f / --force: removes any prior file that would match the resulting fixed filename

See also fix-paths-in-tree.sh for a multifile, recursive version thereof.
"

# Stops in case of command failure:
set -e

# Absolutely needed, as otherwise sed will fail when using "È" as a parameter,
# in ${sed} 's|È|e|g...
#
export LANG=

# Necessary for iconv to handle properly 'È' for example:
export LC_ALL=fr_FR.UTF-8

sed="$(which sed | grep -v ridiculously)"
mv="$(which mv | grep -v ridiculously)"
#tr="$(which tr | grep -v ridiculously)"

porcelain=1
force=1


if [ "$1" = "-h" ] || [ "$1" = "--help" ]; then

	echo "${usage}"

	exit

fi


if [ "$1" = "-p" ] || [ "$1" = "--porcelain" ]; then

	porcelain=0
	shift

fi


if [ "$1" = "-f" ] || [ "$1" = "--force" ]; then

	force=0
	shift

fi


if [ $# -eq 0 ]; then

	echo "  Error, no argument given. ${usage}" 1>&2

	exit 20

fi


# Gathers all elements:
original_path="$*"

if [ ! -e "${original_path}" ]; then

	echo "  Error, no entry named '${original_path}' exists.
${usage}" 1>&2

	exit 25

fi

#echo "Original path is: <${original_path}>"

# To remove any leading path such as "./" or "../foo/bar/":
cd "$(dirname "${original_path}")"

original_name="$(basename "${original_path}")"

#echo "Original name is: <${original_name}>, in $(pwd)."



# More efficient:
# sed -e 's|[ËÈÍÎ]|e|' -e 's|[‡·‚„‰Â]|a|'

# Tested yet not working:
#
# iconv -f $enc -t ASCII//TRANSLIT for all enc in $(iconv --list)
# iso-8859-1 or iso-8859-15

# tr 'È' 'e'


# This iconv command has been a nightmare to obtain (see fr_FR.UTF-8 above).
#
# Useless then:
#
# | ${sed} 's|È|e|g' | ${sed} 's|Ë|e|g' | ${sed} 's|Í|e|g' | ${sed} 's|‡|a|g' | ${sed} 's|‚|a|g' | ${sed} 's|‡|a|g' | ${sed} 's|Ó|i|g' | ${sed} 's|˚|u|g' | ${sed} 's|˘|u|g' | ${sed} 's|Ù|o|g' | ${sed} 's|Ú|o|g'
#
# 's|-\.|-|1' replaced with 's|-\.|.|1' to better manage extensions (preferring
# '*.pdf' to '*-pdf').
#
# ('--' filtered twice intentionally)
#
# (any leading '-' removed - at the path root or below - otherwise seen as an
# option)
#
# (sed 's|\-||g' removed, as inappropriate)
#

# (sed "s|'||g" replaced with sed "s|'|-|g", as "RÈunion" was becoming "R'eunion"
# and this led to "R-eunion"; now obtaining "Reunion")
#
#
corrected_name=$(printf '%s\n' "$original_name" | iconv -f UTF-8 -t ASCII//TRANSLIT | ${sed} -e 's| |-|g' -e 's|"||g' -e 's|\^|-|g' -e 's|`||g' -e 's|:|-|g' -e 's|/|-|g' -e 's|\\|-|g' -e 's|\.\.|.|g' -e 's|\[|-|g' -e 's|\]|-|g' -e 's|(||g' -e 's|)||g' -e 's|\||-|g' -e 's|\.\.|.|g' -e 's|\,|.|g' -e "s|'e|e|g" -e "s|'|-|g" -e 's|\.-|.|g' -e 's|!|-|g' -e 's|?|-|g' -e "s|&|-|g" -e 's|-+|-|g' -e 's|-\.|.|1' -e 's|^-||1' -e 's|-$||' -e 's|\.PNG$|.png|' -e 's|-$||' -e 's|\.JPEG$|.jpeg|' -e 's|\.JPG$|.jpeg|' -e 's|--*|-|g')


#echo "Corrected name is: <${corrected_name}>"


if [ "${original_name}" != "${corrected_name}" ]; then

	if  [ -f "${corrected_name}" ]; then

		if [ $force -eq 0 ]; then

			[ $porcelain -eq 0 ] || echo "(auto-removing a prior '${corrected_name}')"

			/bin/rm -f "${corrected_name}"

		else

			echo "

		Error, an entry named <${corrected_name}> already exists (while in '$(pwd)'), corrected name for <${original_name}> collides with it, remove <${corrected_name}> first.
		" 1>&2

			exit 30

		fi

	fi

	if [ $porcelain -eq 1 ]; then

		echo "  '${original_name}' renamed to '${corrected_name}'"

	fi


	# '--' to stop parsing options, otherwise an entry starting with a dash
	# would be interpreted as an option:
	#
	"${mv}" -f -- "${original_name}" "${corrected_name}"

#else

	#if [ $porcelain -eq 1 ]; then
    #   echo "  (<${original_name}> left unchanged)"
    #fi

fi

if [ $porcelain -eq 0 ]; then

	echo "${corrected_name}"

fi
