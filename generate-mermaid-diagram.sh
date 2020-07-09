#!/bin/sh

usage="Usage: $(basename $0) -h | --help | some_mermaid_file.mmd: generates a PNG file corresponding to specified file describing a Mermaid diagram.
More information: https://mermaid-js.github.io/mermaid/"


# Obtained on Arch with:
#  - first, as root: pacman -Sy yarn
#  - then, as user: mkcd ~/${mermaid_cli_root} && yarn add mermaid.cli
#
mermaid_cli_root="${HOME}/Software/mermaid/"



img_generator="${mermaid_cli_root}/node_modules/.bin/mmdc"

if [ ! -x "${img_generator}" ]; then

	echo "  Error, no Mermaid command-line interface found (searched '${img_generator}')." 1>&2

	exit 5

fi

if [ ! $# -eq 1 ]; then

	echo "  Error, a single argument expected.
$usage" 1>&2

	exit 5

fi


if [ $1 = "-h" ] || [ $1 = "--help" ]; then

	echo "$usage"

	exit 0

fi


# Ex: foobar.mmd
source_file="$1"

target_file=$(echo "${source_file}" | sed 's|\.mmd$|.png|1')


#echo "source_file = ${source_file}"
#echo "target_file = ${target_file}"


if [ "${target_file}" = "${source_file}" ]; then

	echo "  Error, invalid input file ('${source_file}'), expecting *.mmd." 1>&2

	exit 10

fi

${img_generator} -i "${source_file}" -o "${target_file}"

if [ $? -eq 0 ]; then

	echo "
  Success, '${target_file}' generated."

else

	echo "  Error, generation of '${target_file}' from '${source_file}' failed." 1>&2

	exit 25

fi