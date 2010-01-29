#!/bin/sh

USAGE="$0 <my html file>: tidies the html code in chosen file"

# See: http://tidy.sourceforge.net/

TIDY_PATH=${OSDL_ROOT}/src/conf/LOANI-installations/tidy/bin 

TIDY=`PATH=${TIDY_PATH}:${PATH} which tidy 2>/dev/null`

if [ ! -x "$TIDY" ] ; then 
	TIDY="/usr/local/Logiciels/tidy/bin/tidy"
fi


if [ ! -x "$TIDY" ] ; then 
	echo "Unable to find any tidy executable, aborting."
	exit 1
fi

echo "Using ${TIDY}"


TIDY_CONF_FILE="$CEYLAN_ROOT/src/conf/tidy.conf"
TIDY_OPT="-modify -config $TIDY_CONF_FILE"

echo

targetFile="$1"

if [ -z "$targetFile" ]; then
	echo "$USAGE (no file argument given)"
	exit 1
fi

if [ ! -f "$targetFile" ]; then
	echo "$USAGE ($targetFile: file not found)"
	exit 2
fi

if [ ! -f "$TIDY_CONF_FILE" ] ; then
	echo "$USAGE (tidy configuration file $TIDY_CONF_FILE not found)"
	exit 3
fi

echo "    Tidying $1"
$TIDY $TIDY_OPT $targetFile | grep -v Info 
