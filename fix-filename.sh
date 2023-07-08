#!/bin/sh

# Absolutely needed, as otherwise sed will fail when using "י" as a parameter,
# in ${sed} 's|י|e|g...
#
export LANG=

# Necessary for iconv to handle properly 'י' for example:
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
# sed -e 's|[טיךכ]|e|' -e 's|[אבגדהו]|a|'

# Tested yet not working:
#
# iconv -f $enc -t ASCII//TRANSLIT for all enc in $(iconv --list)
# iso-8859-1 or iso-8859-15

# tr 'י' 'e'


# This iconv command has been a nightmare to obtain (see fr_FR.UTF-8 above).
#
# Useless then:
#
# | ${sed} 's|י|e|g' | ${sed} 's|ט|e|g' | ${sed} 's|ך|e|g' | ${sed} 's|א|a|g' | ${sed} 's|ג|a|g' | ${sed} 's|א|a|g' | ${sed} 's|מ|i|g' | ${sed} 's|û|u|g' | ${sed} 's|ש|u|g' | ${sed} 's|פ|o|g' | ${sed} 's|ע|o|g'
#
# 's|-\.|-|1' replaced with 's|-\.|.|1' to better manage extensions (preferring
# '*.pdf' to '*-pdf').
#
# ('--' filtered twice intentionally)
# (any leading '-' removed - at the path root or below - otherwise seen as an option)
# (removed, as inappropriate: | sed 's|\-||1')
#
corrected_name=$(echo "${original_name}" | iconv -f UTF-8 -t ASCII//TRANSLIT | ${sed} 's| |-|g' | ${sed} 's|--|-|g' | ${sed} 's|\[|-|g' | ${sed} 's|\]|-|g' | ${sed} 's|(||g'| ${sed} 's|)||g' | ${sed} 's|\.\.|.|g'| ${sed} 's|\,|.|g' | ${sed} 's|\.-|.|g' | ${sed} 's|!|-|g' | ${sed} 's|?|-|g' | ${sed} "s|'|-|g " | ${sed} "s|&|-|g " | ${sed} 's|--|-|g' | ${sed} 's|--|-|g'| ${sed} 's|-\.|.|1' | sed 's|^-||1' | ${sed} 's|-$||1' | ${sed} 's|.PNG$|.png|1' | ${sed} 's|-$||1' | ${sed} 's|.JPG$|.jpeg|1')


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
