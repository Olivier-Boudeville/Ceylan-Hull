#!/bin/sh

usage="Usage: $(basename $0): corrects the filesystem permissions for the most common file extensions, for all files in the current directory (non-recursively)."


echo "Correcting the file permissions in $(pwd)..."

for f in *.doc *.docx *.xls *.xlsx *.ppt *.pptx *.pdf *.txt *.zip *.png *.jpg *.jpeg *.gz *.tgz *.bz2 *.xz *.rst *.gif *.png *.jpeg *.mp4 *.gpg *.cxx *.hxx *.erl; do

	if [ -f "$f" ]; then

		chmod -x "$f"

	fi

done

echo "...done"
