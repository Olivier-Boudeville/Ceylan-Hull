#!/bin/sh

listing_file="${HOME}/$(date "+%Y%m%d")-archive-listing-for-$(basename $(pwd)).txt"

usage="Usage: $(basename $0): enumerates in current directory all files, specifies their name, size and MD5 sum, and stores the result in ${listing_file}."

echo ${usage}

echo "

	Listing archive content (done by Hull's list-for-backup.sh script):


" > ${listing_file}


files=$(find . -type f)

for f in ${files}; do

	md5=$(md5sum $f | awk '{ print $1 }')
	size=$(du -sh $f | awk '{ print $1 }')

	printf  "%6s  %32s  %s\n" ${size} ${md5} $f >> ${listing_file}

done

echo "Listing file generated in ${listing_file}."
