#!/bin/sh

usage="Usage: $(basename $0) [-h|--help] [ARGS]: runs VS Code (Microsoft Visual Studio Code) or VSCodium (a version of it without branding/telemetry/licensing), a free software (MIT licence) source-code multi-platform editor.

Applies any proxy being currently set in the current shell.
"

# Possibly installed on Arch thanks to: 'pacman -Sy code'.


if [ "$1" = "-h" ] || [ "$1" = "--help" ]; then

	echo "${usage}"

	exit 0

fi



export PATH="${HOME}/Software/VS-Code/VSCode-linux-x64/bin:${PATH}"

vscode_exec="$(which code 2>/dev/null)"

if [ ! -x "${vscode_exec}" ]; then

	echo "  Error, no VS Code installation found (no 'code' executable found)." 1>&2

	exit 5

fi


# Our conventions:
if [ -n "${PROXY}" ]; then
	echo "(using proxy '${PROXY}')"
	proxy_args="--proxy-server=\"${PROXY}\""
else
	echo "(no proxy used)"
fi


args="$* ${proxy_args}"

#echo "Running '${vscode_exec} ${args}'."

"${vscode_exec}" ${args}
