#!/bin/sh

LISTING_FILE="$HOME/"`date "+%Y%m%d"`"-archive-listing.txt"

USAGE="Enumerates in current directory all files, specifies their name, size and MD5 sum, and stores the result in $LISTING_FILE."

echo $USAGE

echo "

	Listing archive content (by Ceylan's list-for-backup.sh script) : 
	

" > $LISTING_FILE


FILES=`find . -type f`

for f in ${FILES} ; do

	MD5=`md5sum $f | awk '{ print $1 }'`
	SIZE=`du -sh $f | awk '{ print $1 }'`
	
	printf  "%6s  %32s  %s\n" $SIZE $MD5 $f >> $LISTING_FILE
	
done

echo "Listing file generated in $LISTING_FILE." 

