#!/bin/sh


USAGE=`basename $0`" : generates automake-specific rules to specify the sources of test programs, based on their name, from current directory."

for t in test*.cc; do
	program_name=`echo $t | sed 's|.cc$||1'`
	echo "${program_name}_exe_SOURCES = $t"
done

# Sorted alphabetically, but no formatting done to respect columns.
