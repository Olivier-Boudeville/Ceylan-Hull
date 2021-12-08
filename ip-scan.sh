#!/bin/sh

default_prefix="192.168"

usage="Usage: $(basename $0) [-h|--help] [IP_PREFIX=XXX.YYY]
Scans all IPs with IP_PREFIX (default one being ${default_prefix}), searching for ICMP ping answers (useful to locate some devices in a local network).
Ex: $(basename $0) 192.100
"

if [ $# -ge 2 ]; then

	echo "
${usage}" 1>&2

	exit 5

fi

if [ "$1" = "-h" ] || [ "$1" = "-h" ]; then

	echo "${usage}"

	exit 0

fi

prefix="$1"

if [ -z "${prefix}" ]; then
	prefix="192.168"
fi

log_file="ip-scan.log"


output_message()
{

	echo $* >> ${log_file}
	echo $*

}

output_message "Searching ICMP-responding IP addresses in prefix '${prefix}' at $(date)"
output_message

a=0
b=1

while [ ${a} -le 255 ]; do

	echo " - exploring range ${prefix}.${a}.1-255"

	while [ ${b} -le 255 ]; do
		#echo "a=${a}, b=${b}"
		target="${prefix}.${a}.${b}"
		#echo "Testing ${target}"
		if ping ${target} -c 1 1>/dev/null; then
			output_message "++++ Found ${target}!!!!!"
		else
			output_message "(nothing at ${target})"
		fi
		b=$(expr ${b} + 1)
	done

	a=$(expr ${a} + 1)
	b=1

done

output_message "End of search at $(date)"
