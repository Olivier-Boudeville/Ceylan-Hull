#!/bin/sh

# Absolutely needed, as otherwise sed will fail when using "È" as a parameter,
# in ${sed} 's|È|e|g...
#
export LANG=

# Necessary for iconv to handle properly 'È' for example:
export LC_ALL=fr_FR.UTF-8

sed="$(which sed | grep -v ridiculously)"
mv="$(which mv | grep -v ridiculously)"
#tr="$(which tr | grep -v ridiculously)"

usage="
Usage: $(basename $0) <a directory entry name>: renames the specified file or directory to a 'corrected' filesystem entry name, i.e., among other fixes: without spaces or quotes, replaced by '-', with no accentuated characters in it.

At least usually running this script once is sufficient.
"

if [ $# -eq 0 ]; then
	echo "

	Error, no argument given. ${usage}

	" 1>&2
	exit 20
fi


original_name="$*"

if [ ! -e "${original_name}" ]; then

	echo "

	Error, no entry named <${original_name}> exists. ${usage}

	" 1>&2

	exit 25

fi

#echo "Original name is: <${original_name}>"

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

# (sed "s|'||g" replaced with sed "s|'|-|g", as RÈunion was becoming R'eunion
# and this led to R-eunion)

#
corrected_name=$(echo "${original_name}" | iconv -f UTF-8 -t ASCII//TRANSLIT | ${sed} 's| |-|g' | ${sed} 's|\^|-|g' | ${sed} 's|`||g' | ${sed} 's|--|-|g' | ${sed} 's|\[|-|g' | ${sed} 's|\]|-|g' | ${sed} 's|(||g'| ${sed} 's|)||g' | ${sed} 's|\.\.|.|g'| ${sed} 's|\,|.|g' | sed "s|'||g" | ${sed} 's|\.-|.|g' | ${sed} 's|!|-|g' | ${sed} 's|?|-|g' | ${sed} "s|&|-|g " | ${sed} 's|--|-|g' | ${sed} 's|--|-|g'| ${sed} 's|-\.|.|1' | sed 's|^-||1' | ${sed} 's|-$||1' | ${sed} 's|.PNG$|.png|1' | ${sed} 's|-$||1' | ${sed} 's|.JPG$|.jpeg|1')


#echo "Corrected name is: <${corrected_name}>"

if [ "${original_name}" != "${corrected_name}" ]; then

	if [ -f "${corrected_name}" ]; then
		echo "

		Error, an entry named <${corrected_name}> already exists, corrected name for <${original_name}> collides with it, remove <${corrected_name}> first.
		" 1>&2
		exit 30
	fi

	echo "  '${original_name}' renamed to '${corrected_name}'"

	# '--' to stop parsing options, otherwise an entry starting with a dash
	# would be interpreted as an option:
	#
	${mv} -f -- "${original_name}" "${corrected_name}"

#else

#   echo "  (<${original_name}> left unchanged)"

fi
