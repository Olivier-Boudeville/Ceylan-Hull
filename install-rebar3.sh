#!/bin/sh

# Installs from sources by default:
use_prebuilt=1

prebuilt_opt="--prebuilt"

software_dir="${HOME}/Software"

rebar3_target="${software_dir}/rebar3"

usage="Usage: $(basename $0) [-h|--help] [-p|${prebuilt_opt}]: installs properly a recent version of rebar3, by default from its sources (then requires 'git' to be available), according to our conventions (notably the installation is to be done in ${rebar3_target}/ - a directory that can be added to the PATH).

Updating a prior rebar3 installation requires just to hide/remove any existing ${rebar3_target} before running this script.

If the '-p' or '${prebuilt_opt}' option is specified, downloads and installs a prebuilt version of rebar3 instead (then requires 'wget' to be available)."

# See https://www.rebar3.org/docs/getting-started

# Note: quite often, the version obtained from sources was broken and/or had
# issues with at least some proxies, so maybe with a prebuilt binary it will be
# better.

if [ "$1" = "-h" ] || [ "$1" = "--help" ]; then

	echo "${usage}"
	exit 0

fi

if [ "$1" = "-p" ] || [ "$1" = "${prebuilt_opt}" ]; then

	use_prebuilt=0
	echo "A prebuilt version of rebar3 will be installed."
	shift

#else
	#echo "(rebar3 will be installed from sources)"

fi


if [ ! $# -eq 0 ]; then

	echo "  Error, too many arguments.
${usage}" 1>&2
	exit 5

fi


if [ $use_prebuilt -eq 0 ]; then

	dir_name="rebar3-prebuilt"

	rebar_target_dir="${software_dir}/${dir_name}"

	if [ -d "${rebar_target_dir}" ]; then

		echo "  Error, a '${rebar_target_dir}' target directory already exists, please remove it first." 1>&2

		exit 10

	fi

	prebuilt_rebar3_url="https://s3.amazonaws.com/rebar3/rebar3"

	echo " Installing a prebuilt version of rebar3, from ${prebuilt_rebar3_url}."

	mkdir -p "${rebar_target_dir}"

	cd "${rebar_target_dir}"

	wget="$(which wget 2>/dev/null)"

	if [ ! -x "${wget}" ]; then

		echo "  Error, wget is not available." 1>&2
		exit 20

	fi

	if "${wget}" --quiet ${prebuilt_rebar3_url}; then

		chmod +x ./rebar3

	else

		echo "  Failed to download a prebuilt version of rebar3 from ${prebuilt_rebar3_url}." 1>&2

		exit 15

	fi

else

	dir_name="rebar3-from-sources"

	rebar_target_dir="${software_dir}/${dir_name}"

	if [ -d "${rebar_target_dir}" ]; then

		echo "  Error, a '${rebar_target_dir}' target directory already exists, please remove it first." 1>&2

		exit 20

	fi

	clone_url="https://github.com/erlang/rebar3.git"

	echo " Installing rebar3 from sources (${clone_url})."

	mkdir -p "${software_dir}"

	cd "${software_dir}"

	git="$(which git 2>/dev/null)"

	if [ ! -x "${git}" ]; then

		echo "  Error, git is not available." 1>&2
		exit 21

	fi


	#echo "Cloning..."

	if ! "${git}" clone ${clone_url} "${dir_name}"; then

		echo " Installation from sources failed (clone)." 1>&2

		exit 50

	fi


	if ! cd "${dir_name}"; then

		echo " Installation from sources failed (cd)." 1>&2

		exit 51

	fi


	echo "Bootstrapping..."

	if ! ./bootstrap; then

		echo " Installation from sources failed (bootstrap)." 1>&2

		exit 52

	fi

fi

cd ..

# To prevent the next link to be created in any prior rebar3 directory:
if [ -L "rebar3" ]; then
	/bin/rm -f rebar3
fi

ln -sf --no-target-directory "${dir_name}" rebar3

echo " Installation success; please ensure that the '${rebar3_target}' directory is in your PATH for good, and that it is not eclipsed (e.g. by a /usr/local/bin/rebar3); this just installed version is: $(${rebar3_target}/rebar3 -v)."
