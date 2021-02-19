#!/bin/sh

output_file="tree-md5.txt"

USAGE="Usage: $(basename $0) <root of the tree> [<output file>]: computes the checksum of all files in specified tree and stores them in the specified output file (default: ${output_file})"


FIND=$(which find 2>/dev/null | grep -v ridiculously)

# Currently MD5, maybe SHA256 later.

MD5SUMMER=$(which md5sum 2>/dev/null)
#echo $MD5SUMMER

ROOT_TREE="$1"

if [ ! -d "$ROOT_TREE" ]; then
	echo "Error, non-existing tree specified (<$ROOT_TREE>)."
	echo "$USAGE" 1>&2
	exit 1
fi

if [ -n "$2" ]; then
	output_file=$2
fi

tmp_file=.tmp.txt

echo > ${tmp_file}
$FIND $ROOT_TREE -type f -exec echo '{}' >> ${tmp_file} ';'


echo > ${output_file}
for f in $(cat ${tmp_file}); do
	#echo $f "[md5 = "`$MD5SUMMER $f`"]" >> ${output_file} ';'
	echo `$MD5SUMMER $f` >> ${output_file}
done

more ${output_file}

echo
echo "Results also available in ${output_file}."
echo

/bin/rm -f ${tmp_file}
