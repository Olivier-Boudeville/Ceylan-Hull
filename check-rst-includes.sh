#!/bin/sh


echo "Checking that all RST files are included once and only once."
echo "(to be executed from the root of document sources, ex: trunk/src/doc)"

INCLUDE_LIST=list-includes.txt

SOURCES=`wh --quiet --no-path \*rst`

regrep --quiet 'include::' \*rst > ${INCLUDE_LIST}

echo "For each RST source file, there must be exactly one include in ${INCLUDE_LIST}"
echo


for f in ${SOURCES}; do
    
	count=`grep "include:: $f" ${INCLUDE_LIST} | wc -l`
    
    if [ "$count" = "1" ] ; then
    	echo "(source $f referenced one time as expected.)"
    elif [ "$count" = "0" ] ; then
    	echo "######## [KO] Source $f never referenced."
        echo
    else
    	echo "######## [KO] Source $f referenced $count times, in:"
        grep "include:: $f" ${INCLUDE_LIST} | sed 's|:...*||1'
        echo
    fi
    
done

echo "
End of reference checking."

rm -f ${INCLUDE_LIST}
