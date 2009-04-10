#!/bin/sh

USAGE="$0 [--simulate]: this script is to be used to empty the trash (${TRASH}) that can be filled thanks to srm"

do_simulate=1


if [ "$1" = "--simulate" ] ; then
	do_simulate=0
	echo "Simulation mode activated."
fi


if [ -z "$TRASH" ]; then
	echo "$0: error, no \$TRASH variable defined" 1>&2
	exit 5
fi


if [ ! -d ${TRASH} ] ; then
	echo "$0: error, no trash directory (${TRASH}) available, nothing to empty." 1>&2	
	exit 10
fi

echo
echo "Emptying trash ($TRASH)"

unset value
read -p "Deleting too old trash content? (y/n) [n]: " value

if [ "$value" = "y" ]; then 

	echo "Deleting..."

	# Deletes all files (everything which is not a directory)
	# under $TRASH which have not been accessed for 30 days or more.
	
	if [ $do_simulate -eq 0 ] ; then
		echo "Would have deleted files:" 
		find "$TRASH" -not -type d -atime +30 -print
	else	
		find "$TRASH" -not -type d -atime +30 -print0 | xargs --null --no-run-if-empty /bin/rm -f 
		
		if [ ! $? -eq 0 ] ; then
			echo "An error occured while deleting old files, aborting." 1>&2
			exit 15
		fi
	fi
	

	# Removes all empty directories under $TRASH:
	
	if [ $do_simulate -eq 0 ] ; then
	
		find "$TRASH" -depth -mindepth 1 -type d -empty -print0 | xargs echo "Would have deleted directories:"
	else
		find "$TRASH" -depth -mindepth 1 -type d -empty -print0 | xargs --null --no-run-if-empty /bin/rmdir

		if [ ! $? -eq 0 ] ; then
			echo "An error occured while deleting empty directories, aborting." 1>&2
			exit 20
		fi
	fi
	
	

  	echo "... done"
	
	echo
else
	echo "Cancelled!"
fi	
			
