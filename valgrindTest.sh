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

. "${shell_location}/termUtils.sh"

#findSupplementaryShellTools

setDebugMode on

target="$1"
shift
user_options="$*"

valgrind=`which valgrind 2>/dev/null`


showResult()
{

	test_target="$1"
	valgrind_log_file="$2"
	error_code="$3"
	exec_output_file="$4"
	printColor "Showing run result for $test_target:" $cyan_text $blue_back
	setText $red_text $white_back
	/bin/more ${valgrind_log_file}
	setText $white_text $black_back

	if [ $error_code -eq 0 ] ; then
		printColor "Successful run for $test_target." $green_text $black_back
		exit 0
	else
		text="Run for $test_target returned a non-null error code ($error_code), full output was:
"`cat $exec_output_file`
		printColor "${text}" $red_text $black_back
		exit $error_code
	fi

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


# As it will be updated at each test:
setText $white_text $black_back


base_target=`basename $target`

valgrind_log_file="$base_target-valgrind.log"

exec_output_file="$base_target-output.log"

# To generate suppressions for later reuse:
#generate_suppression_opt=""
generate_suppression_opt="--gen-suppressions=all"


# To take into account previously recorded suppressions:
#
# (they are generally obtained thanks to the previous generate_suppression_opt
# above, and stored in suppression files stored in
# trunk/src/conf/foobar-valgrind-suppressions.txt, symbolic-linked at the root
# of the user directory: ln -s trunk/src/conf/foobar-valgrind-suppressions.txt
# ~/.foobar-valgrind-suppressions.txt)
#
suppression_opt=""

suppression_files=`/bin/ls ~/.*-valgrind-suppressions.txt 2>/dev/null`

if [ -n "${suppression_files}" ] ; then

	DISPLAY "Using suppression information in following file(s): ${suppression_files}."
	for f in ${suppression_files} ; do
		suppression_opt="${suppression_opt} --suppressions=$f"

	done

fi



#valgrind_options="--tool=memcheck --leak-check=full --show-reachable=yes --num-callers=6 --trace-children=yes --log-file=`basename $target`-%p-valgrind.log"

valgrind_options="--tool=memcheck --leak-check=full --show-reachable=yes --log-file=${valgrind_log_file} -q ${suppression_opt} $generate_suppression_opt"

#valgrind_options=""

#valgrind_advanced_options="--verbose"
valgrind_advanced_options=""

echo "
Testing ${target} thanks to valgrind."

for f in `basename $target`.pid* $valgrind_log_file; do
	DEBUG "Removing old log file $f."
	${RM} -f $f
done



DEBUG "Launching $valgrind $valgrind_options $valgrind_advanced_options $*"

#echo $valgrind $valgrind_options $target $user_options
$valgrind $valgrind_options $target $user_options 1>${exec_output_file} 2>&1

error_code=$?


if [ ! -f "${valgrind_log_file}" ] ; then

	ERROR "
No Valgrind log file was produced."
	exit 10

else

	DISPLAY "End of Valgrind test, output can be read in ${valgrind_log_file}."
	showResult $base_target ${valgrind_log_file} $error_code ${exec_output_file}

fi
