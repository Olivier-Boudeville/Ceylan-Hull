# This script is expected only to be sourced, not executed.


# This script is made to be used by other scripts, so that be a simple
# ". termUtils.sh" should define all text facilities.

# This term helper script contains:
# 	- text style handling functions
#	- all-purpose terminal functions

# This is ISO-6429 color code.

# Use this script as a state-machine:
# change current_text and/or current_back and/or current_att
# (ex: current_back=${green_back})
# then call:
# updateTermState
#

# Created 2003, December 21
# by Olivier Boudeville (olivier.boudeville@online.fr)

# Source: dircolors -p

# Tells whether this script has already been sourced:
termutils_sourced=0

# This script does not depend on any helper script.


# Not in debug mode by default (default: 1).
do_debug=1

# Debug informations go to file by default (default: 0).
do_debug_in_file=0

# Default debug filename:
debug_file="debug.txt"

# Do not output debug to screen by default (default: 1).:
do_debug_to_screen=1


# Flag set to 0 (true) when printf (echo counterpart) is available 
# (default: 1). 
printf_available=1


# Flag set to 0 (true) when color is supported (default: 1).
term_support_color=1


# Text color codes:

text_color_list="black_text red_text green_text yellow_text blue_text magenta_text cyan_text white_text"

black_text=30
red_text=31
green_text=32
yellow_text=33
blue_text=34
magenta_text=35
cyan_text=36
white_text=37


# Background color codes:

back_color_list="black_back red_back green_back yellow_back blue_back magenta_back cyan_back white_back"

black_back=40
red_back=41
green_back=42
yellow_back=43
blue_back=44
magenta_back=45
cyan_back=46
white_back=47


# Attributes:

text_att_list="none_att bold_att underscore_att blink_att reverse_att concealed_att"

none_att=00
bold_att=01
underscore_att=04
blink_att=05
reverse_att=07
concealed_att=08


# Default settings:

default_text_color=${white_text}
default_back_color=${black_back}
default_att=${none_att}


# State for term setting: 

current_text=${default_text_color}
current_back=${default_back_color}
current_att=${default_att}


# Memory initial settings:

save_text_color=${default_text_color}
save_back_color=${default_back_color}
save_att_color=${default_att}


# Default offset for printing text:
term_offset="   "

# Section marker to emphasize on titles:
term_primary_marker="+    "

# Section marker to emphasize on subtitles:
term_secondary_marker="${term_offset}.    "


setText()
# Changes the text settings: text color, maybe back color and/or text
# attribute.
# Usage: setText <text color> [<back color>] [<attribute>]
{
	current_text=${1}
	#DEBUG "current_text is now $current_text"
	
	if [ -n "${2}" ] ; then
		current_back="${2}"
		#DEBUG "current_back is now $current_back"
	fi
	
	if [ -n "${3}" ] ; then
		current_att="${3}"
		#DEBUG echo "current_att is now $current_att"
	fi	
	
	updateTermState
	
}


setDebugMode()
# Set the debug mode.
# Usage: setDebugMode [ on | off ]
{
	if [ -z "$1" ] ; then
		do_debug=0
		DEBUG "Debug mode activated"
		return
	fi
	
	if [ "$1" = "on" ] ; then
		do_debug=0
		DEBUG "Debug mode activated"
	else
		# Anything, but on, leads to off:
		DEBUG "Debug mode deactivated"
		do_debug=1
	fi
}


color_enabled_terms="linux linux-c mach-color console con132x25 con132x30 con132x43 con132x60 con80x25 con80x28 con80x30 con80x43 con80x50 con80x60 xterm xterm-debian rxvt screen screen-w vt100 cygwin"


updateColorSupport()
# Sets term_support_color to true (0) if this terminal supports colors,
# otherwise returns false (1), if not in list.
# Usage: updateColorSupport
{
 
 	which printf 1>/dev/null 2>&1
	if [ $? -eq 0 ] ; then
		printf_available=0		
		DEBUG "printf is available."
	else
		printf_available=1		
		DEBUG "printf is not available."
	fi
		
	if [ -z "$TERM" ]; then
		DEBUG "No TERM environment variable set, assuming terminal does not support color."
		term_support_color=1		
	fi
	
	for t in $color_enabled_terms ; do
		if [ "$t" = "$TERM" ] ; then
			  DEBUG "This term supports color."
			  term_support_color=0
			  return 0
		fi	   
	done
	
    DEBUG "This term does not support color."
	return 1
	
}


updateTermState()
# Updates the state machine with current settings.
# Usage: updateTermState
{
	if [ "$term_support_color" -eq 0 ] ; then
	
		if [ "$printf_available" -eq 0 ] ; then
			printf "[${current_att};${current_text};${current_back}m"
		else
			# Too many newlines !
			echo "[${current_att};${current_text};${current_back}m"
		fi
		
	fi
}


saveTermSettings()
# Stores current term state for future recovery with loadTermSettings() 
# Usage: saveTermSettings
{
	save_text_color=${current_text}
	save_back_color=${current_back}
	save_att_color=${current_att}
}


loadTermSettings()
# Retrieves last saved term state (with saveTermSettings()) and 
# updates term state. 
# Usage: loadTermSettings
{
	setText ${save_text_color} ${save_back_color} ${save_att_color}
}


printColor()
# Prints a one-line message in defined style (color, backcolor, attribute).
# Usage: printColor <message> [<color> [<back color> [<attribute>]]] 
{

	saveTermSettings
	if [ -n "$2" ] ; then
		setText $2 $3 $4
	fi
	
	if [ "$printf_available" -eq 0 ] ; then
		printf "$1"
		loadTermSettings
		echo
	else
		echo "$1"
		loadTermSettings
	fi 
	
}


printColorAtomic()
# Prints a message in defined style (color, backcolor, attribute) atomatically,
# i.e. without,if possible, inserting a new line afterwards.
# Usage: printColor <message> [<color> [<back color> [<attribute>]]] 
{

	saveTermSettings
	if [ -n "$2" ] ; then
		setText $2 $3 $4
	fi
	
	if [ "$printf_available" -eq 0 ] ; then
		printf "$1"
		loadTermSettings
	else
		echo "$1"
		loadTermSettings
	fi 
	
}


printBeginList()
# Prints text corresponding to the end of list whose name is provided.
# Usage: printBeginList <list name>
{
	printColorAtomic "      ----> $1: "
}


printItem()
# Prints a list item according to the color-enabled style, with a leading space.
# Usage: printItem [<message>+]
{
	if [ "$term_support_color" -eq 0 ] ; then	
		printColorAtomic "$* "
	else		
		echo "        + $*"
	fi	
}


printEndList()
# Prints text corresponding to end of list.
# printEndList
{
		echo 
}


printOK()
# Prints a colorful [OK], with a leading space. 
# Usage: printOK
{
	
	if [ "$term_support_color" -eq 0 ] ; then
		printColorAtomic "[" "$white_text"
		printColorAtomic "OK" "$green_text"
		printColorAtomic "] " "$white_text"
	else
		echo "[OK]"	
	fi
}


printFailed()
# Prints a colorful [Failed], with a leading space. 
# Usage: printFailed
{
	
	if [ "$term_support_color" -eq 0 ] ; then
		printColorAtomic "[" "$white_text"
		printColorAtomic "Failed" "$red_text"
		printColorAtomic "] " "$white_text"
	else
		echo "[Failed]"	
	fi
}


printNA()
# Prints a colorful [N/A], with a leading space.
# Usage: printNA
{
	
	if [ "$term_support_color" -eq 0 ] ; then
		printColorAtomic "[" "$white_text"
		printColorAtomic "N/A" "$blue_text"
		printColorAtomic "] " "$white_text"
	else
		echo "[N/A]"		
	fi
}


printNonImplemented()
# Prints a colorful [Not implemented], with a leading space.
# Usage: printNonImplemented
{
	
	if [ "$term_support_color" -eq 0 ] ; then
		printColorAtomic "[" "$white_text"
		printColorAtomic "Not implemented" "$yellow_text"
		printColorAtomic "] " "$white_text"
	else
		echo "[Not implemented]"	
	fi
}


display_color=$white_text

DISPLAY()
# Displays normal messages in standard channel.
# Usage: DISPLAY [<message>+]
{
	printColor "$*" $display_color
}


debug_color=$cyan_text

DEBUG()
# Displays provideds message in standard channel, if in DEBUG mode
# (do_debug set to "0").
# Usage: DEBUG [<message>+]
{

	if [ $do_debug -eq 0 ] ; then
	
		if [ $do_debug_to_screen -eq 0 ] ; then
		
			if [ "$term_support_color" -eq 0 ] ; then
				saveTermSettings
				setText $debug_color
				echo "Debug: $*"
				loadTermSettings
			else
				echo $*
			fi	
		fi		
		
		if [ $do_debug_in_file -eq 0 ] ; then
			echo "Debug: $*" >> $debug_file
		fi
				
	fi
	
}


TRACE()
# Displays trace messages in standard error channel.
# Usage: TRACE [<message>+]
{
	printColor "Trace: $*" $magenta_text 1>&2
}


WARNING()
# Displays warning messages in standard error channel.
# Usage: WARNING [<message>+]
{
	printColor "Warning: $*" $yellow_text 1>&2
}


ERROR()
# Display error messages in standard error channel.
# Usage: ERROR [<message>+]
{
	printColor "Error: $*" $white_text $red_back 1>&2
}


setDefaultTerm()
# Restores defaults.
# Usage: setDefaultTerm
{
	setText ${default_text_color} ${default_back_color} ${default_att}
}


default_wait_for_key_message="< Press any key >"


waitForKey()
# Displays the specified message (if any, otherwise the default one)
# and waits for any key to be pressed.
# Usage: waitForKey [prompt message]
{ 

	if [ -z "$1" ] ; then
		# The '-s -n1' options are not supported everywhere:
		read -p "$default_wait_for_key_message" utils_key_pressed
	else
		read -p "$*" utils_key_pressed
	fi	
	
	unset utils_key_pressed
	echo
}


beep_util="/usr/bin/beep"

beep()
# Makes your computer make, if available, an unpleasant noise. 
# Usage: beep
{

	if [ -x "$beep_util" ] ; then
		$beep_util
	else	
		printf "\007"
		printf "\007"
		printf "\007"
	fi
}


askDefaultYes()
# Let the user choose between a yes/no alternative, yes being the default.
# Returns 0 if yes, 1 otherwise.
# Usage: if askDefaultYes "Do you want to exit ?" ; then ...
{
	unset returnedChar
	read -p "$1 (y/n) [y] " returnedChar

	if [ "$returnedChar" = "n" ] ; then
		return 1
	else
		return 0
	fi
}


askDefaultNo()
# Let the user choose between a yes/no alternative, no being the default.
# Returns 0 if yes, 1 otherwise.
# Usage: if askDefaultNo "Do you want to exit ?" ; then ...
{
	unset returnedChar
	read -p "$1 (y/n) [n] " returnedChar 

	if [ "$returnedChar" = "y" ] ; then
		return 0
	else
		return 1
	fi
}


askString()
# Let the user enter a string after the provided prompt.
# Returns the entered string.
# Usage: askString "Enter your credit card number:"
#	  echo $returnedString
{

	read -p "$1 " returnedString

}


askNonVoidString()
# Let the user enter a non-void string after the provided prompt.
# Loops until something is entered.
# Returns the entered string.
# Usage: askNonVoidString "Enter your credit card number:"
#	  echo $returnedString
{
	returnedString=""
	
	while [ -z "$returnedString" ] ; do
		askString "$1"
	done
}


# Auto-run when sourced, to set color flag:
updateColorSupport
