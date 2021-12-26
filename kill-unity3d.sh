#!/bin/sh

help_short_opt="-h"
help_long_opt="--help"

wipe_short_opt="-w"
wipe_long_opt="--wipe-persistent-state"

usage="Usage: $(basename $0) [${help_short_opt}|${help_long_opt}] [${wipe_short_opt}|${wipe_long_opt}]: kills all processes related to Unity3D (including UnityHub).
This may be useful if for example the Unity editor is freezing when importing assets in a project.
If requested, also wipes out all persistent state of UnityHub and Unity3D itself (not including any user projects).
"

if [ "$1" = "${help_short_opt}" ] || [ "$1" = "${help_long_opt}" ]; then

	echo "${usage}"

	exit

fi


if [ $# -gt 1 ]; then

	echo "  Error, too many parameters.
${usage}" 1>&2

	exit 5

fi


do_wipe=1

if [ "$1" = "${wipe_short_opt}" ] || [ "$1" = "${wipe_long_opt}" ]; then

	echo "  (Unity persistent state will be wiped out)"

	do_wipe=0

	shift

fi


if [ -n "$1" ]; then

	echo "  Error, invalid argument.
${usage}" 1>&2

	exit 10

fi


echo "Killing all processes in link with Unity3D:"
ps -edf | grep -i unity | grep -v grep | grep -v $(basename $0)

process_targets="unityhub-bin Unity Unity.Licensing.Client UnityPackageManager UnityShaderCompiler"

# Softly first:
killall ${process_targets} 2>/dev/null

# Then brutally:
killall -9 ${process_targets} 2>/dev/null


echo
echo "Unity3D processes killed; remaining:"
ps -edf | grep -i unity | grep -v grep | grep -v $(basename $0)


if [ $do_wipe -eq 0 ]; then

	echo
	echo "Please confirm that Unity persistent state shall be wiped out. Proceed? [y/N]"

	read value

	if [ "${value}" = "y" ]; then

		echo "Wiping out..."

		# To wipe all persistent state (except projects themselves):
		# (nothing in ~/.cache)
		#
		/bin/rm -rf ~/.config/UnityHub/ ~/.local/share/UnityHub/ 2>/dev/null
		/bin/rm -rf ~/.config/unity3d/ ~/.local/share/unity3d/ 2>/dev/null

		echo "...done"

	else

		echo "Warning: Unity wipe out cancelled." 1>&2

	fi

fi
