#!/bin/sh


USAGE="`basename $0` : remove recursively from current directory all CVS-related directories (CVS or cvs) and their content. Use with caution !"

echo
echo $USAGE
STARTING_DIR=`pwd`

#tree $STARTING_DIR

TARGETS=`find $STARTING_DIR -iname 'CVS' -exec echo '{}' ';'`

if [ -z "$TARGETS" ] ; then
	echo "Nothing to delete, aborting"
	exit 
fi

echo
echo "Spotted directories are :"
find $STARTING_DIR -iname 'CVS' -exec echo '{}' ';'

unset value 

echo
read -p "Will recursively remove all these CVS-related directories (CVS or cvs) and their content starting from $STARTING_DIR : ok ? (y/n) [n]" value

if [ "$value" = "y" ] ; then
	echo "Proceeding with deletion...."
	
	find $STARTING_DIR -iname 'CVS' -exec rm -rf '{}' ';' 2>/dev/null
	
	echo "... done"
else
	echo "Cancelled !"

fi	
