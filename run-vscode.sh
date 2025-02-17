#!/bin/sh

proxy_opt="--enable-proxy"

usage="Usage: $(basename $0) [-h|--help] [${proxy_opt}] [VS_CODE_ARGS]: runs VS Code (Microsoft Visual Studio Code) or VSCodium (a version of it without branding/telemetry/licensing), a free software (MIT licence) source-code multi-platform editor.

Specify the ${proxy_opt} option in order to enable and activate a proxy for this editor instance (by default its proxy access is disabled).
"

# Possibly installed on Arch thanks to: 'pacman -Sy code'.


if [ "$1" = "-h" ] || [ "$1" = "--help" ]; then

	echo "${usage}"

	exit 0

fi


# Ad hoc install as a last resort (typically if obtained via
# https://code.visualstudio.com/docs/?dv=linux64, rather than from a package):
#
export PATH="${PATH}:${HOME}/Software/VS-Code/VSCode-linux-x64/bin:"

vscode_exec="$(which code 2>/dev/null)"

if [ ! -x "${vscode_exec}" ]; then

	echo "  Error, no VS Code installation found (no 'code' executable found)." 1>&2

	exit 5

fi



use_proxy=1

if [ "$1" = "${proxy_opt}" ]; then

	use_proxy=0
	shift

fi


if [ $use_proxy -eq 0 ]; then

	# Our conventions:

	if [ -n "${PROXY}" ]; then

		# Corresponds to our 'set-proxy' alias:

		export http_proxy=${PROXY}
		export https_proxy=${PROXY}

		export HTTP_PROXY=${PROXY}
		export HTTPS_PROXY=${PROXY}

		curl --silent --proxy-negotiate --user : http://google.fr 1>/dev/null

		echo "(using '${http_proxy}' for proxy)"

		proxy_args="--proxy-server=\"${PROXY}\""

	else

		echo "(no proxy used)"

	fi

else

	unset http_proxy
	unset https_proxy
	unset HTTP_PROXY
	unset HTTPS_PROXY

	echo "(no proxy enabled)"

fi


args="$* ${proxy_args}"

echo "(running '${vscode_exec} ${args}')"

"${vscode_exec}" ${args}
