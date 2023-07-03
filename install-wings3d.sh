#!/bin/sh

software_path="${HOME}/Software"

# The build expects literally 'wings', otherwise "can't find include lib
# "wings/e3d/e3d.hrl":
#
#wings_dir="Wings3D"
wings_dir="wings"

wings_path="${software_path}/${wings_dir}/vanilla/wings"

# Reference repository:
wings3d_git="https://github.com/dgud/wings.git"

# Target branch:
wing3d_branch="master"

usage="Usage: $(basename $0) [-h|--help]: installs Wings3D as the current user (no specific rights needed), in '${wings_path}', from its reference GIT (${wings3d_git}), using its '${wing3d_branch}' branch.

Expects the prerequisites to be already available (notably make, Erlang, WxWidgets and OpenGL support).
Refer to https://github.com/dgud/wings/blob/master/BUILD.unix for more details.

Use our 'run-wings3d.sh' script to run Wings3D afterwards."

if [ "$1" = "-h" ] || [ "$1" = "--help" ]; then

	echo "${usage}"

	exit 0

fi

if [ ! "$#" -eq 0 ]; then

	echo "  Error, unexpected argument specified.
${usage}"

	exit 2

fi


erl="$(which erl 2>/dev/null)"

if [ ! -x "${erl}" ]; then

	echo " Error, no Erlang installation found (no 'erl' available on the PATH). One may refer for example to http://myriad.esperide.org/#getting-erlang to secure it." 1>&2

	exit 5

fi


wings3d="$(which wings3d 2>/dev/null)"

if [ -x "${wings3d}" ]; then

	echo "Warning: there is already a wings3d executable found in PATH: '${wings3d}'; cotinuing nevertheless." 1>&2

fi


if [ -d "${wings_path}" ]; then

	echo "Prior clone found in '${wings_path}', updating it."

	cd "${wings_path}"

	if ! (git pull && make clean && make); then

		echo "  Error, unable to update Wings3D." 1>&2
		exit 40

	fi

else

	echo "No prior clone found in '${wings_path}', creating it."

	mkdir -p "${software_path}"

	cd "${software_path}"

	if ! git clone "${wings3d_git}" "${wings_dir}"; then

		echo "  Error, unable to clone Wings3D (from ${wings3d_git})." 1>&2
		exit 50

	fi


	if ! (cd "${wings_dir}" && git checkout "${wing3d_branch}" && make); then

		echo "  Error, unable to build the '{wing3d_branch}' branch of Wings3D." 1>&2
		exit 55

	fi

fi

echo
echo "Build of Wings3D in '${wings_path}' successful; you may use our 'run-wings3d.sh' script to launch it then."
