#!/bin/sh

USAGE="  Usage: "`basename $0`" FILE1 [FILE2 ...]
  Encrypts specified files, and removes their unencrypted sources. See also: decrypt.sh."



crypt_tool_name="gpg"

crypt_tool=`which $crypt_tool_name 2>/dev/null`

if [ ! -x "$crypt_tool" ] ; then

	echo "Error, no encryption tool not found (no $crypt_tool_name)." 1>&2
	exit 5

fi


if [ $# -lt 1 ] ; then

	echo "Error, no file to encrypt specified.
$USAGE" 1>&2
	exit 6
	
fi

rm="/bin/rm -f"

#read -p "Enter encryption password: " pass
#echo "pass = $pass"

crypt_opt=" -c --cipher-algo=AES256"

for f in $* ; do

	if [ -f "$f" ] ; then

		res_file="$f.gpg"
			
		echo " - encrypting file '$f'"
		$crypt_tool $crypt_opt $f
		res="$?"
		
		if [ $res -eq 0 ] ; then
		
			echo "$res_file successfully generated, file $f removed."
			${rm} "$f"
			
		else

			echo "Error, encryption failed (code: $res), stopping, file $f left as is." 1>&2
			exit 10
			
		fi 
		
	else
		echo "  ### Warning: file '$f' not found, skipped." 
	fi

done


echo "Use decrypt.sh to perform the reverse operation."

