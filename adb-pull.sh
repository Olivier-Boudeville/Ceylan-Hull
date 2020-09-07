#!/bin/sh

usage="Usage: $(basename $0) EXPR: allows to download in the current directory, from the already connected and authorizing Android device (typically mobile phone), files and directories (recursively) based on the specified expression(s) (typically wildcards), knowing that adb pull does not support that.\nEx: $(basename $0) /sdcard/DCIM/Camera/IMG_20200530*.jpg"


# To find content (ex: snapshots) in mobile phone:
# $ adb shell
# $ find "/sdcard/" -iname "*.jpg"
#
# Typically found as: /sdcard/DCIM/Camera/IMG_20200525_175458.jpg
#
# So a typical command-line may be:
#   adb-pull.sh /sdcard/DCIM/Camera/IMG_20200710*
#
# See also our fix-snapshots.sh script.

adb_exec=$(which adb 2>/dev/null)


if [ ! -x "${adb_exec}" ]; then

	echo "  Error, adb tool not found." 1>&2
	exit 5

fi


if [ "$1" = "-h" ] || [ "$1" = "--help" ]; then
	echo "$usage"
	exit
fi


args="$*"

if [ -z "${args}" ]; then

	echo -e "  Error, no argument specified.\n ${usage}" 1>&2
	exit 15

fi

${adb_exec} shell ls $1 | tr -s "\r\n" "\0" | xargs -0 -n1 ${adb_exec} pull
