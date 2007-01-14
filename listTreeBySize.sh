#!/bin/sh

echo
echo "Will list all files, starting from current directory, sorted by decreasing size, expressed in kilobytes :"
echo

find . -type f -exec du -k '{}' ';' | sort -nr | more
