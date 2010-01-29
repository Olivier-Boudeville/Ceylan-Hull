#!/bin/sh

RM=/bin/rm

shell_location=`dirname $0`

if [ ! -f "${shell_location}/termUtils.sh" ] ; then
	previous_location=${shell_location}
	shell_location="${CEYLAN_ROOT}/src/code/scripts/shell"
	if [ ! -f "${shell_location}/termUtils.sh" ] ; then
		echo "Error, unable to find defaultLocations helper script (searched in ${previous_location} and in ${shell_location})."
		exit 1
	fi	
fi

source "${shell_location}/termUtils.sh"

#findSupplementaryShellTools

setDebugMode on

target="$1"

valgrind=`which valgrind 2>/dev/null`


showResult()
{
	printColor "Showing run result for $1:" $cyan_text $blue_back
	${MORE} ${log_file}
	printColor "End of run result for $1." $cyan_text $blue_back
	
}



USAGE="\nUsage: "`basename $0`" <executable to test> [<executable arguments>+]: uses Valgrind to perform quality test on executable target."



if [ -z "$valgrind" ] ; then
	ERROR "Valgrind executable not found."
	exit 2	
fi


if [ ! -x "$valgrind" ] ; then
	ERROR "${valgrind} is not an executable file."
	exit 3	
fi

if [ -z "$target" ] ; then
	ERROR "No test target specified. $USAGE"
	exit 4
fi

if [ ! -x "$target" ] ; then
	ERROR "${target}: file not found. $USAGE"
	exit 5	
fi


if [ ! -x "$target" ] ; then
	ERROR "${target} is not an executable file. $USAGE"
	exit 6
fi

#valgrind_options="--tool=memcheck --leak-check=summary --num-callers=6 --trace-children=yes --log-file=`basename $target`"
valgrind_options=""

#valgrind_advanced_options="--verbose"
valgrind_advanced_options=""

echo "Testing ${target} thanks to valgrind."

for f in `basename $target`.pid*; do
	DEBUG "Removing old log file $f."
	${RM} -f $f
done



DEBUG "Launching $valgrind $valgrind_options $valgrind_advanced_options $*"

#echo $valgrind $valgrind_options $*

$valgrind $valgrind_options $*

log_file=`/bin/ls \`basename ${target}\`.pid*`

DISPLAY "End of Valgrind test, output can be read in ${log_file}."

showResult `basename ${target}`
