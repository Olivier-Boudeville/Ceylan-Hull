#!/bin/sh

# Warning: not really tested, a better solution was deemed to erase the
# repository and start again by importing the latest checkout.

# Another solution could have been to add the previous user to the SVN server.


previous_user="$1"
new_user="$2"

if [ ! $# -eq 2 ] ; then

	echo "Error, exactly two parameters needed." 1>&2
	exit 10
	
fi


echo "Previous user is '${previous_user}', new one will be '${new_user}'..."

target_files=`find . -name entries 2>/dev/null`

#echo "Fixed files will be: ${target_files}"

substitute=`which substitute.sh 2>/dev/null`


for f in ${target_files} ; do

	echo "  - fixing $f"
	
	# Read-only by default (-r--r--r--):
	chmod +w "$f"
	${substitute} ${previous_user} ${new_user} "$f"
	chmod 444 "$f"	
	
done


echo "...done"

