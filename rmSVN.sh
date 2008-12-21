#!/bin/sh


USAGE="`basename $0`: removes recursively from current directory all SVN-related directories (.svn) and their content. Use with caution!"

echo
echo $USAGE
STARTING_DIR=`pwd`

#tree $STARTING_DIR

TARGETS=`find $STARTING_DIR -name '.svn' -exec echo '{}' ';'`

if [ -z "$TARGETS" ] ; then
	echo "Nothing to delete, aborting."
	exit 
fi

echo
echo "Spotted directories are:"
find $STARTING_DIR -name '.svn' -exec echo '{}' ';'

unset value 

echo
read -p "   Will recursively remove all these SVN-related directories (.svn) and their content starting from $STARTING_DIR: ok? (y/n) [n]" value

if [ "$value" = "y" ] ; then

	echo "Proceeding with deletion...."
	
	find $STARTING_DIR -name '.svn' -exec /bin/rm -rf '{}' ';' 2>/dev/null
	res=$?
	
	if [ $res -eq 0 ] ; then
	
		echo "... successfully done"
	
	else
		echo "Error, operation failed (code: $res)." 1>&2
		exit 5
	fi
	
else

	echo "Cancelled, nothing done!"

fi	

