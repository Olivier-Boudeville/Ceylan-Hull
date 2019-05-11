#!/bin/sh

usage="$(basename $0) [FILES]: transfers specified files to a connected mobile phone"

sources=$*

#target="/sdcard/"
target="/storage/emulated/0/Transferts-Esperide"

echo " Requested to transfer ${sources} to mobile phone (in ${target})..."

echo "   - if needed, activate first, in the mobile settings, the USB debugging"
echo "   - connect the mobile phone to this computer thanks to a proper USB cable"
echo "   - switch, in the notification showing up on the mobile, from 'USB charging' to 'File transfer'"

echo
echo " < Hit enter when ready to transfer, CTRL-C to abort >"

read

adb shell mkdir ${target} ; adb push ${sources} ${target} && echo "One may use 'Amaze' to browse these files on the mobile now. Check that, if needed, you have a proper viewer (ex: MuPDF)"
