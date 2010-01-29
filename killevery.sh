USAGE="Usage: $0 myProcessNameToKill"

# This script only targets user-owned processes not corresponding to a text editor
# (root would not be able to kill another's user's processes)


if [ $# != 1 ]; then
        echo -e $USAGE
        exit 1
fi

# Debug mode, activated if true (0), default: false (1);
do_debug=1


DEBUG()
{
	[ "$do_debug" == 1 ] || echo "Debug: $*"
}


TARGET=$1


#TARGET=`echo $1 | sed -e 's|^|"|' | sed -e 's|$|"|'`
#echo $TARGET

# Save all editors:
TO_KILL_NAMES=`ps -u \`whoami\` -o args | grep "$TARGET" | grep -v grep | grep -v "$EDITOR " | grep -v "vi " | grep -v "nedit "`

DEBUG "Basic ps: "`ps -u \`whoami\` -o args | grep "$TARGET"`
DEBUG "Spotted process to kill = $TO_KILL_NAMES"

if [ -z "$TO_KILL_NAMES" ]; then 
	echo "There is no process matching <$1>"
else 
	echo "Following processes will be killed:"
	ps  -u `whoami` -o args | grep "$1" | grep -v grep
	read -e -p "Should we kill them ? (y/n) [n]: " choice
	if [ "$choice" == "y" ]; then
		FIRST=`ps -u $(whoami) -o pid,args | grep "$1" | grep -v grep| awk '{print $1}'`
		if [ -n "$FIRST" ]; then
			kill $FIRST
		fi
	SECOND=`ps -u $(whoami) -o pid,args | grep "$1" | grep -v grep| awk '{print $1}'`
		if [ -n "$SECOND" ]; then
			kill -9 $SECOND
		fi
		echo "Killed !"
	else
		echo "$0 cancelled"	
	fi	
	
fi
