#!/bin/sh

help_short_opt="-h"
help_long_opt="--help"

# Before: formatter="$(which astyle 2>/dev/null)"

whitespace_formatter_name="fix-whitespaces.sh"
erlang_formatter_name="erlfmt"
c_like_formatter_name="clang-format"

usage="Usage: $(basename $0) [${help_short_opt}|${help_long_opt}] A_SOURCE_FILE: updates (in-place) the specified source file so that it complies with our conventions, namely:
 - Erlang source and header files (*.erl, *.hrl, *.escript, *.src) are updated according to https://howtos.esperide.org/Erlang.html#formatting-erlang-code (hence based on ${erlang_formatter_name})
 - C/C++ source and header files (*.c, *.cc, *.cpp, *.cxx, *.h, *.hxx) are updated according to https://seaplus.esperide.org/#c-c-code-formatting (hence based on ${c_like_formatter_name})
 - configuration files (i.e. *.config files), documentation files (*.md, *.markdown), script files (*.sh), makefiles (GNUmake*, [Mm]akefile), CSS (*.css) are whitespace-cleaned up (with '${whitespace_formatter_name}')

Expected to be idempotent.
The root of Ceylan-Hull is expected to be in the current PATH.
"



check_erlang_formatter()
{

	erlang_formatter="$(which ${erlang_formatter_name} 2>/dev/null)"

	if [ ! -x "${erlang_formatter}" ]; then

		echo "  Error, no Erlang formatter tool available (no '${erlang_formatter_name}' executable found)." 1>&2

		exit 55

	fi

}


check_c_like_formatter()
{

	c_like_formatter="$(which ${c_like_formatter_name} 2>/dev/null)"

	if [ ! -x "${c_like_formatter}" ]; then

		echo "  Error, no C-like formatter tool available (no '${c_like_formatter}' executable found)." 1>&2

		exit 60

	fi

}



check_whitespace_formatter()
{

	whitespace_formatter="$(which ${whitespace_formatter_name} 2>/dev/null)"

	if [ ! -x "${whitespace_formatter}" ]; then

		echo "  Error, no whitespace cleanup tool available (no '${whitespace_formatter_name}' script found)." 1>&2

		exit 50

	fi

}



reformat_erlang_source_file()
{

	target_file="$1"

	echo " - reformatting Erlang source file '${target_file}'"

	check_erlang_formatter

	# In-place:
	if "${erlang_formatter}" --write "${target_file}"; then

		#echo "(${target_file} successfully reformatted)"
		exit 0

	else

		echo "  Error, the reformatting of '${target_file}' failed." 1>&2
		exit 30

	fi

}



reformat_c_like_source_file()
{

	target_file="$1"

	echo " - reformatting C-like source file '${target_file}'"

	check_c_like_formatter

	# In-place:
	if "${c_like_formatter}" --style=LLVM -i "${target_file}"; then

		#echo "(${target_file} successfully reformatted)"
		exit 0

	else

		echo "  Error, the reformatting of '${target_file}' failed." 1>&2
		exit 35

	fi

}



reformat_base_file()
{

	target_file="$1"

	echo " - reformatting base file '${target_file}'"

	check_whitespace_formatter

	# In-place:
	if "${whitespace_formatter}" --quiet "${target_file}"; then

		#echo "(${target_file} successfully reformatted)"
		exit 0

	else

		echo "  Error, the reformatting of '${target_file}' failed." 1>&2
		exit 40

	fi

}



if [ "$1" = "${help_short_opt}" ] || [ "$1" = "${help_long_opt}" ]; then

   echo "${usage}"
   exit 0

fi


if [ ! $# -eq 1 ]; then

	echo "  Error, this script expects exactly one argument.
${usage}" 1>&2

	exit 10

fi


target_file="$1"

if [ ! -f "${target_file}" ]; then

	echo "  Error, no file to reformat found as '${target_file}'.
${usage}" 1>&2

	exit 20

fi


# Normalising all extensions to lowercase first:

extension="$(echo ${target_file}| sed 's|^.*\.||1' | tr '[:upper:]' '[:lower:]')"

#echo "Extension found for '${target_file}' is: ${extension}"

case "${extension}" in

	"erl")
		reformat_erlang_source_file "${target_file}"
		;;

	"hrl")
		reformat_erlang_source_file "${target_file}"
		;;

	"escript")
		reformat_erlang_source_file "${target_file}"
		;;

	"src")
		reformat_erlang_source_file "${target_file}"
		;;


	"c")
		reformat_c_like_source_file "${target_file}"
		;;

	"cc")
		reformat_c_like_source_file "${target_file}"
		;;

	"cpp")
		reformat_c_like_source_file "${target_file}"
		;;

	"cxx")
		reformat_c_like_source_file "${target_file}"
		;;

	"h")
		reformat_c_like_source_file "${target_file}"
		;;

	"hxx")
		reformat_c_like_source_file "${target_file}"
		;;


	"config")
		reformat_base_file "${target_file}"
		;;

	"md")
		reformat_base_file "${target_file}"
		;;

	"markdown")
		reformat_base_file "${target_file}"
		;;

	"sh")
		reformat_base_file "${target_file}"
		;;


	*)
		if [ "${target_file}" = "GNUmakefile" ] || [ "${target_file}" = "makefile" ] || [ "${target_file}" = "Makefile" ] [ "${target_file}" = ".gitignore" ]; then

			reformat_base_file "${target_file}"

		else

			#echo "Unsupported extension ('${extension}'), nothing done."
			exit 0

		fi
		;;

esac
