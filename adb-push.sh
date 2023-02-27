#!/bin/sh

remote_dir="/sdcard"
#remote_dir="/storage/emulated/0/Transferts-Esperide"


usage="Usage: $(basename $0) EXPR: uploads specified local files, possibly based on expressions (typically wildcards), to the already connected and authorizing Android device (typically a smartphone), in its '${remote_dir}' directory.
Ex: $(basename $0) /tmp/foobar.pdf"



if [ "$1" = "-h" ] || [ "$1" = "--help" ]; then

	echo "${usage}"

	exit 0

fi

adb_exec=$(which adb 2>/dev/null)

if [ ! -x "${adb_exec}" ]; then

	echo "  Error, adb tool not found." 1>&2
	exit 5

fi


args="$*"

if [ -z "${args}" ]; then

	echo "  Error, no argument specified.
${usage}" 1>&2
	exit 15

fi


echo " Requested to transfer ${args} to device (in ${remote_dir})..."
echo "   - if needed, activate first, in the device settings, the USB debugging"
echo "   - connect the device to this computer thanks to a proper USB cable"
echo "   - switch, in the notification showing up on the device, from 'USB charging' to 'File transfer'"
echo
#echo " < Hit enter when ready to transfer, CTRL-C to abort >"
#read

${adb_exec} shell mkdir ${remote_dir} 2>/dev/null

${adb_exec} push ${args} ${remote_dir} && echo "One may use 'Amaze' to browse these files on the device now, in ${remote_dir}. Check that, if needed, you have a proper viewer (ex: MuPDF) for that."
