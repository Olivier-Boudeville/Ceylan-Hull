#!/bin/sh

usage="Usage: $(basename $0) EXPR: downloads in the current directory, from the already connected and authorising ('Developer Options' -> 'USB Debugging' being enabled in the settings, and 'File transfer' being selected on USB connection) Android device (typically a smartphone), files and directories (recursively) based on the specified expression(s) (typically wildcards) - knowing that a mere 'adb pull' does not support that.

This script will try to run adb on the smartphone as root.

For example:
  $(basename $0) /sdcard/DCIM/Camera/*.jpg
  $(basename $0) /sdcard/DCIM/Camera/IMG_$(date '+%Y%m%d')*.jpg
  $(basename $0) /storage/emulated/0/Download/foo*bar*.pdf
  $(basename $0) /storage/emulated/0/Documents/*
"

# To find content (e.g. snapshots) in one's mobile phone:
# $ adb shell
# $ find "/sdcard/" -type f -a -iname "*.jpg" 2>/dev/null
#
# Typically found as: /sdcard/DCIM/Camera/IMG_20200525_175458.jpg
#
# So a typical command-line may be:
#   adb-pull.sh /sdcard/DCIM/Camera/IMG_20200710*
#
# See also our fix-snapshots.sh script.

adb_exec="$(which adb 2>/dev/null)"


if [ ! -x "${adb_exec}" ]; then

	echo "  Error, adb tool not found." 1>&2
	exit 5

fi


if [ "$1" = "-h" ] || [ "$1" = "--help" ]; then

	echo "${usage}"
	exit

fi


args="$*"

if [ -z "${args}" ]; then

	echo "  Error, no argument specified.
${usage}" 1>&2
	exit 15

fi


echo " Requested to transfer locally '${args}' from device..."
echo "   - if needed, activate first, in the device settings ('Developer Options'), the USB debugging"
echo "   - connect the device to this computer thanks to a proper USB cable (note that most of them are not durably reliable...) "
echo "   - switch, in the notification showing up on the device, from 'USB charging' to 'File transfer' (if no notification opos up, then maybe this cable has only the wiring for charging, not for data?)"
echo
#echo " < Hit enter when ready to transfer, CTRL-C to abort >"
#read


if ${adb_exec} root 2>/dev/null; then

	echo "(adb run as root on the smartphone)"

else

	# Maybe is already good?
	echo "(not able to switch adb as root on the smartphone)"

fi


#${adb_exec} shell ls ${args} | tr -s "\r\n" "\0 " | xargs -0 -n1 ${adb_exec} pull

# Apparently will work now only one at a time:
for f in $(${adb_exec} shell ls ${args} | tr -s "\r\n" "\0 "); do ${adb_exec} pull "$f"; done
