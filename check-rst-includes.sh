#!/bin/sh


echo "Checking that all RST files are included once and only once."
echo "(to be executed from the root of document sources, ex: trunk/src/doc)"

WH=`which wh`

if [ ! -x "$WH" ] ; then

	echo "Error, wh script not found." 1>&2
	exit 10
	
fi

REGREP=`which regrep`

if [ ! -x "$WH" ] ; then

	echo "Error, regrep script not found." 1>&2
	exit 11
	
fi
 
include_list_file="list-includes.txt"

sources=`$WH --quiet --exclude-path tmp-rst --no-path \*.rst`

#echo "Source RST files: ${sources}"


$REGREP -r --quiet 'include::' > ${include_list_file}

#echo "Each RST source file should be included exactly once."
echo


for f in ${sources}; do
    
	count=`grep "include:: $f" ${include_list_file} | wc -l`
    
    if [ "$count" = "1" ] ; then
    	res=`grep "include:: $f" ${include_list_file} | sed 's|:...*||1' | xargs basename` 
    	echo "(source $f referenced one time as expected, in ${res})"
    elif [ "$count" = "0" ] ; then
    	echo "######## [KO] Source $f never referenced."
        echo
    else
    	echo "######## [KO] Source $f referenced $count times, in:"
        grep "include:: $f" ${include_list_file} | sed 's|:...*||1'
        echo
    fi
    
done

echo "
End of reference checking."

/bin/rm -f ${include_list_file}

