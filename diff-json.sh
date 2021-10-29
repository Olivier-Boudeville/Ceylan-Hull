#!/bin/sh

usage="Usage: $(basename $0) FIRST_JSON_FILE SECOND_JSON_FILE [-h|--help]: compares the two specified JSON files, once their content has been put in a canonical, sorted form (knowing notably that their keys are allowed to be in arbitrary order).

Note that due to this on-the-fly transformation made for comparison purpose (of course the original files are not modified), their conten used for comparison may be slightly alterered (ex: a "1.0" value in an original file may be compared as if it was "1", i.e. an integer value).

Options:
   -h or --help: this help"


# Needed early to be able to shift:
if [ "$1" = "-h" ] || [ "$1" = "--help" ]; then
	echo "${usage}"
	exit 0
fi


jq="$(which jq 2>/dev/null)"

if [ ! -x "${jq}" ]; then
	echo "  Error, no 'jq' tool found." 1>&2
	exit 10
fi


meld="$(which meld 2>/dev/null)"

if [ ! -x "${meld}" ]; then
	echo "  Error, no 'meld' tool found." 1>&2
	exit 15
fi


if [ ! $# -eq 2 ]; then

	echo "  Error, two parameters expected.
${usage}" 1>&2

	exit 20

fi



first_file_path="$1"

if [ ! -e "${first_file_path}" ]; then

	echo "  Error, first specified file, '${first_file_path}', does not exist.
${usage}" 1>&2
	exit 30

fi


second_file_path="$2"

if [ ! -e "${second_file_path}" ]; then

	echo "  Error, second specified file, '${second_file_path}', does not exist.
${usage}" 1>&2
	exit 35

fi


# We ensure that the two temporary filenames cannot collide (if comparing the
# same filenames in different directories):

#first_canonical_file_path="$(mktemp) $(basename ${first_file_path})-XXXX"
first_canonical_file_path="/tmp/$(basename ${first_file_path})-first"

#second_canonical_file_path="$(mktemp) $(basename ${second_file_path})-XXXX"
second_canonical_file_path="/tmp/$(basename ${second_file_path})-second"

if ! ${jq} --sort-keys . < "${first_file_path}" > "${first_canonical_file_path}"; then

	echo "  Error, canocalisation of '${first_file_path}' failed." 1>&2
	exit 50

fi


if ! ${jq} --sort-keys . < "${second_file_path}" > "${second_canonical_file_path}"; then

	echo "  Error, canocalisation of '${second_file_path}' failed." 1>&2
	exit 55

fi


${meld} "${first_canonical_file_path}" "${second_canonical_file_path}" 1>/dev/null

/bin/rm -f "${first_canonical_file_path}" "${second_canonical_file_path}"
