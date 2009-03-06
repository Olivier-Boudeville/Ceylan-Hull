#!/bin/sh

USAGE="  Usage: "`basename $0`" FILE1 [FILE2 ...]
  Decrypts specified files (does not remove their encrypted sources). See also: crypt.sh."

crypt_tool_name="gpg"

crypt_tool=`which $crypt_tool_name 2>/dev/null`

if [ ! -x "$crypt_tool" ] ; then

	echo "Error, no decryption tool not found (no $crypt_tool_name)." 1>&2
	exit 5

fi


if [ $# -lt 1 ] ; then

	echo "Error, no file to decrypt specified.
$USAGE" 1>&2
	exit 6
	
fi

#rm="/bin/rm -f"

decrypt_opt=" -d"

for f in $* ; do

	if [ -f "$f" ] ; then
	
		echo " - decrypting file '$f'"

		decrypted_file=`echo $f | sed 's|.gpg$||1'`
		if [ -f "${decrypted_file}" ] ; then
			echo "Error, target file '$decrypted_file' is already existing, remove it first ($f has NOT been decrypted), stopping." 1>&2
			exit 15 
		fi
		
		$crypt_tool $decrypt_opt $f > $decrypted_file 
		res="$?"
		
		if [ $res -eq 0 ] ; then
		
			
			echo "$decrypted_file successfully decrypted (file $f still available)."
			
		else

			echo "Error, decryption failed (code: $res), stopping." 1>&2
			exit 10
			
		fi 
		
	else
		echo "  ### Warning: file '$f' not found, skipped." 
	fi

done

