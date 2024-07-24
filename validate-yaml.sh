#!/bin/sh

usage="Usage: $(basename $0) YAML_FILE: validates the specified YAML file.

Typically for those who do not have the 'yq' tool available."

yaml_file="$1"

if [ -z "${yaml_file}" ]; then

	echo "  Error, no YAML file specified.
${usage}" 1>&2

	exit 5

fi

shift


if [ -n "$*" ]; then

	echo "  Error, extra parameters specified ($*).
${usage}" 1>&2

	exit 10

fi


if [ ! -f "${yaml_file}" ]; then

	echo "  Error, the specified YAML file ('${yaml_file}') does not exist." 1>&2

	exit 15

fi

echo

yq="$(which yq 2>/dev/null)"

if [ -x "${yq}" ]; then

	#echo "(using 'yq')"

	if ! "${yq}" . "${yaml_file}"; then

		echo "  Validation (with 'yq') of '${yaml_file}' failed." 1>&2

		exit 50

	fi


else

	pip install pyyaml

	if ! python -c 'import yaml, sys; print(yaml.safe_load(sys.stdin))' < "${yaml_file}"; then

		echo "  Validation (with Python yaml) of '${yaml_file}' failed." 1>&2

		exit 55

	fi

fi

echo "Validation of '${yaml_file}' succeeded!"
