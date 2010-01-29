# This helper script provides a useful toolbox.
# Meant to be sourced.

# Creation date: 2004, February 22.
# Author: Olivier Boudeville (olivier.boudeville@online.fr)



testAsk()
{
    unset value
    value=`askGdialog "Please enter your age" "26"`
    echo "Answer is $?"
}


askTextold() 
# Usage: 
#	askText "my prompt" "my default value"
#	myVariable=$value
#	Affect after that call your target variable with the variable named "value"
{
	unset value
	read -e -p " + $1 [$2]: " value
	if [ -z $value ]; then
            value=$2
	fi
	echo 
	return 
}


askText() 
# Usage: 
#	if [ askText "my prompt" "my default value" ]; then
#		myVariable=$value
#	else
#		echo "Cancel"
#	You should set after that call your target variable with the variable
# named "value"
#   
{
	read -e -p " + $1 [$2]: " value
	if [ -z $value ]; then
            value=$2
	fi
 }


testAskText()
{
	if askText "This is a testing prompt" "This is a default value" ; then
		echo "Specified value is $value"
	else
		echo "Cancel requested" # Never gets here
	fi
}


askGDIALOG() 
# Usage: 
#	askGDIALOG "my title" "my prompt" "my default value"
#	myVariable=$value
#	Affect after that call your target variable with the variable named "value"
{
 if $GDIALOG --title "$1" --inputbox "$2" 20 20 "$3" ; then
    echo $?
 fi
}


testAskGDIALOG()
{
	if askGDIALOG "This is my title" "This is a prompt" "This is a default value" ; then
		echo "Specified value is $value"
	else
		echo "Cancel requested" # Never gets here
	fi
}

isXRunning()
# Usage: if isXRunning; then
#      
# This test should be improved, I do not know which is the reliable 
# way to test whether X is running.
{  
 if [ `ps -edf | grep "/etc/X11/X " | grep -v grep 1>/dev/null` ]; then
  return 0 
 fi
 return 1
}


setGUIFunctions()
{
 ASK="ask$GUI"
}


detectGUI()
# Usage:
#       detectGUI
# prefers gdialog to kdialog (both if X running) to dialog to whiptail
# to text only (which is always available default)    
{

GUI="$FULLTEXT" 

if [ -n `availableCommand "$GDIALOG"` -a isXRunning ]; then
 GUI="GDIALOG"
 setGUIFunctions
 return 0
fi


if [ -n `availableCommand "$KDIALOG"` -a isXRunning ]; then
 GUI="$KDIALOG"
 return 0
fi


if [ -n `availableCommand "$DIALOG"` ]; then
 GUI="$DIALOG"
 return 0
fi


if [ -n `availableCommand "$WHIPTAIL"` ]; then
 GUI="$WHIPTAIL"
 return 0
fi

setGUIFunctions

}



test()
{
if gdialog --title "An Input Box" \
        --inputbox "This box accepts a message." 200 200
    then echo $?
else echo "No text input."
fi
detectGUI
echo "Selected GUI is $GUI"
askGdialog "a prompt" "a value"
echo $value
waitForKey
}


do_simulated()
{



if [ ! "$do_simulate" = "yes" ]; then
wget $SDL_DOWNLOAD_LOCATION/$SDL_ARCHIVE 1>/dev/null
tar xvzf $SDL_ARCHIVE 1>/dev/null
rm $SDL_ARCHIVE
fi


echo -e "\nFollowing the download step is the compilation step: SDL, Ceylan and OSDL will be compiled, er, successfully."

echo -e "\nCompiling SDL ..."
cd $ROOT_INSTALL/SDL-$SDL_VERSION
if [ ! "$do_simulate" = "yes" ]; then

fi

echo -e "\nCompiling Ceylan ..."
cd $ROOT_INSTALL/$CEYLAN_ROOT/src
make

echo -e "\nCompiling OSDL ..."
cd $ROOT_INSTALL/$OSDL_ROOT/src
if [ ! "$do_simulate" = "yes" ]; then
make
fi

echo -e "\nThen they will all work their gentle way."   
cd $ROOT_INSTALL/$OSDL_ROOT/src/code/tests
./playTests.sh

#echo "Please insert your credit card and enter its expiration date, followed by the pound sign:"

echo -e "\n\n\tHave fun with OSDL !"
}

##### Effective main script

#testAvailableCommand
#testAskText
testAskGDIALOG

waitForKey
detectGUI
echo $ASK
$ASK
testAsk

waitForKey
