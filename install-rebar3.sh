#!/bin/sh

# Installs from sources by default:
use_prebuilt=1

prebuilt_opt="--prebuilt"

usage="Usage: $(basename $0) [-h|--help] [${prebuilt_opt}]: installs properly a recent version of rebar3, by default from its sources.
If the '${prebuilt_opt}' option is specified, downloads and installs a prebuilt version of rebar3 instead."

# See https://www.rebar3.org/docs/getting-started

# Note: quite often, the version obtained from sources was broken, so maybe with
# a prebuilt binary it will be better.

if [ "$1" = "-h" ] || [ "$1" = "--help" ]; then

	echo "${usage}"
	exit 0

fi

if [ "$1" = "${prebuilt_opt}" ]; then

	use_prebuilt=0
	echo "A prebuilt version of rebar3 will be installed."
	shift

else

	echo "rebar3 will be installed from sources."

fi


if [ ! $# -eq 0 ]; then

	echo "  Error, too many arguments.
${usage}" 1>&2
	exit 5

fi

software_dir="${HOME}/Software"


rebar_target_dir="${software_dir}/rebar3"

if [ -d "${rebar_target_dir}" ]; then

	echo "  Error, a '${rebar_target_dir}' target directory already exists, please remove it first." 1>&2

	exit 10

fi



if [ $use_prebuilt -eq 0 ]; then

	prebuilt_rebar3_url="https://s3.amazonaws.com/rebar3/rebar3"

	echo " Installing a prebuilt version of rebar3, from ${prebuilt_rebar3_url}."

	mkdir -p "${rebar_target_dir}"

	cd "${rebar_target_dir}"

	if wget --quiet ${prebuilt_rebar3_url}; then

		chmod +x ./rebar3

	else

		echo "  Failed to download a prebuilt version of rebar3 from ${prebuilt_rebar3_url}." 1>&2

		exit 15

	fi

else

	clone_url="https://github.com/erlang/rebar3.git"

	echo " Installing rebar3 from sources (${clone_url})."

	mkdir -p "${software_dir}"

	cd "${software_dir}"

	git clone ${clone_url} && cd rebar3 && ./bootstrap

	if [ ! $? -eq 0 ]; then

		echo " Installation from sources failed." 1>&2

		exit 50

	fi

fi

echo " Installation success, please ensure that the '${rebar_target_dir}' directory is in your PATH for good."

exit 0
