#!/bin/sh

usage="Usage: $(basename $0) A_GENERATED_FILE\n \
 Forces a remake of specified generated file (e.g. '.o' or '.beam')."


if [ ! $# -eq 1 ]; then

	printf "  Error, exactly one parameter expected.\n \
 ${usage}" 1>&2

	exit 5

fi

target="$1"

ext=$(echo "${target}" | sed 's|^.*\.||1')

#echo "extension is '$ext'."

case "${ext}" in

	"erl")

		real_target=$(echo "${target}" | sed 's|\.erl$|.beam|1')
		echo "  (real target selected for rebuild: '${real_target}', from '${target}')"

		#echo "  Error, not removing a '.erl' file." 1>&2
		#exit 50

		;;


	"c")

		real_target=$(echo "${target}" | sed 's|\.c$|.o|1')
		echo "  (real target selected for rebuild: '${real_target}', from '${target}')"

		#echo "  Error, not removing a '.c' file." 1>&2
		#exit 51

		;;

	*)

		real_target=${target}

esac


if [ -f "${real_target}" ]; then

	srm "${real_target}" 1>/dev/null
	#/bin/rm -f "${real_target}"

	echo "('${real_target}' removed)"

fi

make "${real_target}"
