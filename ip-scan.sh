#!/bin/sh

usage="Usage: $(basename $0) [PREFIX=XXX.YYY]
Scans all IPs with PREFIX, searching for ICMP ping answers (useful to locate some devices in a local network).
Ex: $(basename $0) 192.168
"

if [ $# -ge 2 ]; then

	echo -e  "${usage}" 1>&2
	exit 5

fi


PREFIX="$1"

if [ -z "$PREFIX" ]; then
	PREFIX="192.168"
fi

LOG_FILE="ip-scan.log"


output_message()
{

	echo $* >> $LOG_FILE
	echo $*

}

output_message "Searching ICMP-responding IP addresses in prefix '$PREFIX' at "`date`
output_message

A=0
B=1

while [ $A -le 255 ]; do

	echo " - exploring range $PREFIX.$A.1-255"

	while [ $B -le 255 ]; do
		#echo "A=$A, B=$B"
		TARGET="$PREFIX.$A.$B"
		#echo "Testing $TARGET"
		ping $TARGET -c 1 1>/dev/null
		if [ $? -eq 0 ]; then
			output_message "++++ Found $TARGET!!!!!"
		else
			output_message "(nothing at $TARGET)"
		fi
		B=`expr $B + 1`
	done

	A=`expr $A + 1`
	B=1
done

output_message "End of search at $(date)"
