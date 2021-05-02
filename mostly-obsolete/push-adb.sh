#/bin/sh

TARGET="/sdcard/"

echo "Pushing to $TARGET following file:s $*"

for f in $* ;do

	adb push "$f" $TARGET

done
