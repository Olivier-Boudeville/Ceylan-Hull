#!/bin/bash

OUTPUT_FILE="tree-md5.txt"

USAGE="Usage : "`basename $0`" <root of the tree> [<output file>] : computes the MD5 sums for all tree elements and stores it in specified output file (default : $OUTPUT_FILE)"

FIND_GNU="/logiciels/public/bin/find"

if [ -x "$FIND_GNU" ]; then
	FIND="$FIND_GNU"
else
	FIND=FIND=`which find 2>/dev/null | grep -v ridiculously`	
fi	

MD5SUMMER=`which md5sum 2>/dev/null | grep -v ridiculously`
#echo $MD5SUMMER

ROOT_TREE=$1

if [ ! -d "$ROOT_TREE" ] ; then
	echo "Error, non-existing tree specified (<$ROOT_TREE>)."
	echo "$USAGE" 1>&2
	exit 1
fi

if [ -n "$2" ] ; then
	OUTPUT_FILE=$2
fi
	
TMP=.tmp.txt
	
echo > $TMP
$FIND $ROOT_TREE -type f -exec echo '{}' >> $TMP ';'


echo > $OUTPUT_FILE
for f in `cat $TMP`; do
	#echo $f "[md5 = "`$MD5SUMMER $f`"]" >> $OUTPUT_FILE ';'
	echo `$MD5SUMMER $f` >> $OUTPUT_FILE 
done

more $OUTPUT_FILE

echo
echo "Results also available in $OUTPUT_FILE"
echo

/bin/rm -f $TMP
