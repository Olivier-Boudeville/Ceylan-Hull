#!/bin/bash

# Created 2004, February 21
# by Olivier Boudeville (olivier.boudeville@online.fr)


TEST_TARGET="defaultLocations.sh"

USAGE="This script test the ${TEST_TARGET} script."


if [ ! -f "$TEST_TARGET" ] ; then
	echo "Error : no $TEST_TARGET script available for sourcing."
	exit
fi

source ${TEST_TARGET}

# Activates debug mode :
do_debug=0

echo
echo "The value of GREP before findTool is $GREP."
findTool grep
GREP=$returnedString
echo "The value of GREP after findTool is $GREP."

be_strict=1

echo
echo "The value of UNEXISTINGTOOL before findTool is $UNEXISTINGTOOL."
findTool unexistingtool
UNEXISTING_TOOL=$returnedString
echo "The value of UNEXISTINGTOOL after findTool is $UNEXISTINGTOOL."


# ls is /bin/ls actually :
LS="/usr/bin/ls"

echo
echo "The value of LS before findTool is $LS."
findTool ls
LS=$returnedString
echo "The value of LS after findTool is $LS."

findBasicShellTools

windows_drive="c:"
target_path="/home/sye/Projects/OSDL/OSDL-0.3/src"
target_prefix="${windows_drive}\\installs\\cygwin"

echo "Converting $target_path to windows path with prefix $target_prefix : "
convertToWinPath $target_path $target_prefix
echo "$returnedString"


echo
echo "End of ${TEST_TARGET} test"
echo

