#!/bin/sh

new_year=$(date '+%Y')

usage="Usage: $(basename $0) CODE_TYPE ROOT_DIRECTORY STARTING_YEAR NEW_YEAR NOTICE

Updates the copyright notices of the code of the specified type found from the specified root directory, based on the specified year range.

CODE_TYPE is among:
  - 'C++' (includes C), for *.h, *.h.in, *.cc, *.cpp, *.c files
  - 'Erlang', for *.hrl, *.erl files

For example: $(basename $0) Erlang $HOME/My-program-tree 2001 2013 \"Foobar Ltd\"
This will replace '% Copyright (C) x-y Foobar Ltd' by '% Copyright (C) x-2013 Foobar Ltd' for all x in [2001;2012] in all Erlang files (*.hrl and *.erl) found from $HOME/My-program-tree.

Note that if NOTICE contains characters that are meaningful in terms of Regular Expressions, they must be appropriately escaped.

Example for ampersand (&): $(basename $0) Erlang $HOME/My-program-tree 2008 ${new_year} \"Foobar R\&D Ltd\"
"

# To check whether all (Erlang, here) files have been updated:
#
# git diff --name-only | grep 'rl$' | sort > changed.txt
# find . -name '*.?rl' | sort > all.txt
# meld changed.txt all.txt


# If having forgotten, some years ago, to update the notices (e.g. we are in
# 2013 but you forgot to update the sources in 2012, so you still have
# 20XX-2011, that you want to transform into 20XX-2013), then you may run:
#
# for y in 2009 2010 2011 2012; do update-all-copyright-notices.sh C++ . 2000
# $y "James Bond" ; done

if [ "$1" = "-h" ] || [ "$1" = "--help" ]; then

	echo "${usage}"

	exit 0

fi


if [ ! $# -eq 5 ]; then

	echo "  Error, exactly five parameters are required.

${usage}" 1>&2
	exit 5

fi


code_type="$1"

case "${code_type}" in

	Erlang)
		;;

	C++)
		;;

   *)
		echo "  Error, unknown code type (${code_type}).

${usage}" 1>&2
		exit 10
		;;

esac


root_dir="$2"

if [ -z "${root_dir}" ]; then

	echo "  Error, no root directory specified.

${usage}" 1>&2
	exit 15

fi


if [ ! -d "${root_dir}" ]; then

	echo "  Error, the specified root directory (${root_dir}) does not exist.

${usage}" 1>&2
	exit 20

fi


starting_year="$3"

new_year="$4"

if [ ${new_year} -le ${starting_year} ]; then

	echo "  Error, starting year (here, ${starting_year}) must be strictly lower than new year (${new_year})." 1>&2

	exit 50

fi

max_year=$(expr ${new_year} - 1)

notice="$5"


#echo "starting_year = ${starting_year}"
#echo "new_year = ${new_year}"
#echo "notice = ${notice}"
#echo "max_year = ${max_year}"

years="$(seq --equal-width ${starting_year} ${max_year})"

#echo "years = ${years}"

per_year_script="$(dirname $0)/update-copyright-notices.sh"

#echo "per_year_script = ${per_year_script}"

if [ ! -x "${per_year_script}" ]; then

	echo "  Error, no update script found ('${per_year_script}')." 1>&2

	exit 55

fi

for y in ${years}; do echo "---> searching for year ${y}-${max_year}, to be replaced by ${y}-${new_year} ${notice}"; ${per_year_script} --quiet ${code_type} ${root_dir} "${y}-${max_year} ${notice}" "${y}-${new_year} ${notice}"; echo; done

echo "Replacements done."
