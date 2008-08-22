PREFIX="192.168"

LOG_FILE="ip-scan.log"


output_message()
{

	echo $* >> $LOG_FILE
	echo $*

}

output_message "Searching responding IP addresses in prefix $PREFIX at "`date`
output_message

A=0
B=0

while [ $A -le 255 ] ; do

	while [ $B -le 255 ] ; do
		#echo "A=$A, B=$B"
		TARGET="$PREFIX.$A.$B"
		#echo "Testing $TARGET"
		ping $TARGET  -c 1 1>/dev/null
		if [ $? -eq 0 ] ; then
			output_message "++++ Found $TARGET !!!!!" 
		else 
			output_message "(nothing at $TARGET)"	
		fi
		B=`expr $B + 1`
	done
	
	A=`expr $A + 1`
	B=0	
done

output_message "End of search at "`date`


