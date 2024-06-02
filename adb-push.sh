#!/bin/sh

remote_dir="/sdcard"
#remote_dir="/storage/emulated/0/Transferts-Esperide"

usage="Usage: $(basename $0) EXPR: uploads the specified local files, possibly based on expressions (typically wildcards), to the already connected and authorising ('Developer Options' -> 'USB Debugging' being enabled in the settings, and 'File transfer' being selected on USB connection) Android device (typically a smartphone), in its '${remote_dir}' directory (which will be created if needed).

For example: $(basename $0) /tmp/foobar.pdf"



if [ "$1" = "-h" ] || [ "$1" = "--help" ]; then

	echo "${usage}"

	exit 0

fi

adb_exec="$(which adb 2>/dev/null)"

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


echo " Requested to transfer '${args}' to device (in ${remote_dir})..."
echo "   - if needed, activate first, in the device settings ('Developer Options'), the USB debugging"
echo "   - connect the device to this computer thanks to a proper USB cable (note that most of them are not durably reliable...) "
echo "   - switch, in the notification showing up on the device, from 'USB charging' to 'File transfer' (if no notification opos up, then maybe this cable has only the wiring for charging, not for data?)"
echo
#echo " < Hit enter when ready to transfer, CTRL-C to abort >"
#read

${adb_exec} shell mkdir ${remote_dir} 2>/dev/null

${adb_exec} push ${args} ${remote_dir} && echo "One may use 'Amaze' to browse these files on the device now, in ${remote_dir}. Check that, if needed, you have a proper viewer (e.g. MuPDF) for that."
