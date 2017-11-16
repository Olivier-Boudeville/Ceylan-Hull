#!/bin/sh

USAGE="Usage: $(basename $0): corrects the UNIX permissions for the most common file extensions for all files in the current directory."


echo "Correcting file permissions in $(pwd)..."

for f in *.doc *.docx *.xls *.xlsx *.ppt *.pptx *.pdf *.txt *.zip *.png *.jpg *.jpeg *.gz *.tgz *.bz2 *.xz *.rst ; do

	if [ -f "$f" ] ; then

		chmod -x "$f"

	fi

done


echo "...done"
