#!/bin/sh

echo "Displaying running processes, from the bigger CPU-consumer to the smallest :"
ps -e -o user,pid,pcpu,comm | sort -r -k 3 | more
