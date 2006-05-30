#!/bin/bash


TEST_TARGET="termUtils.sh"

USAGE="This script test the ${TEST_TARGET} script."

# Created 2003, December 21
# by Olivier Boudeville (olivier.boudeville@online.fr)

if [ ! -f "$TEST_TARGET" ] ; then
	echo "Error : no $TEST_TARGET script available for sourcing."
	exit
fi

source ${TEST_TARGET}


initTest()
{
	echo -e "\tTesting terminal display"
	setDefaultTerm
	setDebugMode on
	updateColorSupport
	echo "Using default settings"
}


testTextColors()
{


	echo
	echo
	echo "Testing text colors : "
	echo
	
	for c in $text_color_list ; do
		setText ${!c}
		echo "This is color $c"
		setDefaultTerm
	done
	echo
	
}


testTextAttributes()
{
	echo
	echo
	echo "Testing text attributes : "
	echo

	for a in $text_att_list ; do
		setText ${default_text_color} ${default_back_color} ${!c}
		echo "This is text attribute $a"
		setDefaultTerm
	done
	echo
	
}


testBackColors()
{

	echo
	echo
	echo "Testing background colors : "
	echo

	for c in $back_color_list ; do
		setText ${default_text_color} ${!c}
		printf "This is background color $c"
		setDefaultTerm
		echo
	done
	echo
		
}


testPrintColor()
{
	printColor "This text is in default style"
	printColor "This one is yellow" $yellow_text
	printColor "This text is in default style"
	printColor "This one is blue with red background" $blue_text $red_back
	printColor "This text is in default style"
	echo
}


testSpecialMessages()
{

	setDebugMode
	DEBUG "This is a debug message"
	WARNING "This is a warning message"
	ERROR "This is an error message"
	
}


testInteractions()
{

	echo
	if askDefaultYes "Is your answer yes ?" ; then
		echo "Yes"
	else
		echo "No"
	fi
	
	echo
	
	if askDefaultNo "Is your answer yes ?" ; then
		echo "Yes"
	else
		echo "No"
	fi
	
	askString "Enter your name :"
	echo "Hello, $returnedString !"
	
	askNonVoidString "Enter your credit card number :"
	echo "You should not have told us that your credit card number was $returnedString."
	

}


echo
echo "$USAGE"

initTest
waitForKey

testTextColors
waitForKey

testTextAttributes
waitForKey

testBackColors
waitForKey

testPrintColor
waitForKey

testSpecialMessages

testInteractions

echo
echo "Restoring defaults"
setDefaultTerm


echo
echo "End of ${TEST_TARGET} test"
echo

beep
