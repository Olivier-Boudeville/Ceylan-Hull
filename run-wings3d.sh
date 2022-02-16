#!/bin/sh

usage="Usage: $(basename $0): runs Wings3D; expects it to be already installed (refer to our 'install-wings3d.sh' script for that)."

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

	echo "(running '${wings3d}', as found in PATH)"

	"${wings3d}"

else

	echo "(no wings3d found in PATH)"

	# According to our conventions, and expected to be up to date and built:
	wings_path="${HOME}/Software/wings"

	if [ ! -d "${wings_path}" ]; then

		echo "  Error, no Wings3D installation found (no '{wings_path}'); refer to https://github.com/dgud/wings/blob/master/BUILD.unix and/or use our 'install-wings3d.sh' script." 1>&2

		exit 15

	fi

	echo "(running Wings3D from '${wings_path}')"

	# Would mask potentially interesting messages (ex: w.r.t. OpenCL):
	#exec_opts="-detached"
	exec_opts="-noshell"

	erl -pa "${wings_path}"/ebin -run wings_start start_halt ${exec_opts} &

fi
