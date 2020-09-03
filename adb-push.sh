#!/bin/sh

remote_dir="/sdcard"


usage="Usage: $(basename $0) EXPR: allows to upload specified local files, possibly based on expressions (typically wildcards), to the already connected and authorizing Android device (typically mobile phone), in its '${remote_dir} directory.\nEx: $(basename $0) /tmp/foobar.pdf"

adb_exec=$(which adb 2>/dev/null)

if [ ! -x "${adb_exec}" ]; then

	echo "  Error, adb tool not found." 1>&2
	exit 5

fi


args="$*"

if [ -z "${args}" ]; then

	echo -e "  Error, no argument specified.\n ${usage}" 1>&2
	exit 15

fi

${adb_exec} push ${args} ${remote_dir}
