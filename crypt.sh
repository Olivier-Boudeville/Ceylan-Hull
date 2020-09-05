#!/bin/sh

usage="Usage: $(basename $0) [-h|--help] FILE1 [FILE2 ...]
Encrypts as strongly as reasonably possible the specified files, and removes their unencrypted sources.
See also the decrypt.sh counterpart script."


if [ "$1" = "-h" ] || [ "$1" = "-h" ]; then

	echo "  ${usage}"
	exit 0

fi

crypt_tool_name="gpg"

crypt_tool=$(which $crypt_tool_name 2>/dev/null)

if [ ! -x "$crypt_tool" ]; then

	echo "  Error, no encryption tool not found (no $crypt_tool_name)." 1>&2
	exit 5

fi


if [ $# -lt 1 ]; then

	echo "  Error, no file to encrypt specified.
$usage" 1>&2
	exit 6

fi

rm="/bin/rm -f"

#read -p "Enter encryption password: " pass
#echo "pass = $pass"

# 'gpg --version' returns the available cipher algorithms:
crypt_opt=" -c --cipher-algo=AES256"

for f in $*; do

	if [ -f "$f" ]; then

		res_file="$f.gpg"

		echo " - encrypting file '$f'"
		$crypt_tool $crypt_opt $f
		res="$?"

		if [ $res -eq 0 ]; then

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


echo "Use the decrypt.sh script to perform the reverse operation."
