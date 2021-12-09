#!/bin/sh

verbose=1
default_ip_start="192.168"

usage="Usage: $(basename $0) [-h|--help] [-v|--verbose] [IP_START=XXX.YYY|XXX.YYY.ZZZ]
Scans all IPs starting from IP_START (default one being ${default_ip_start}), searching for ICMP ping answers (useful to locate some devices in a local network). Prerably to be run as a non-priviledged user.

Ex:
 - '$(basename $0) 192.100' will search in 192.100.*.*
 - '$(basename $0) 10.0.77' will search in 10.0.77.*

Note: scanning is slow.
To interrupt a scan, one may use CTRL-C.
"


if [ "$1" = "-h" ] || [ "$1" = "-h" ]; then

	echo "${usage}"

	exit 0

fi

if [ "$1" = "-v" ] || [ "$1" = "--verbose" ]; then

	echo "(verbose mode activated)"
	verbose=0
	shift

fi

if [ $# -ge 2 ]; then

	echo "
${usage}" 1>&2

	exit 5

fi

ip_start="$1"

if [ -z "${ip_start}" ]; then
	#echo "  Error, no IP start specified.
#${usage}" 1>&2

	#exit 10

	ip_start="${default_ip_start}"

fi

# We split an IPv4 address in its 4 components: a.b.c.d.
#
# For d, not keeping:
# - 0, as designating a network
# - 255, as designating a broadcast address

a_start=$(echo "${ip_start}" | awk -F\. '{print $1}')

if [ -z "${a_start}" ]; then
	echo "  Error, invalid IP start specified ('${ip_start}').
${usage}" 1>&2

	exit 50

fi

a_stop="${a_start}"

b_start=$(echo "${ip_start}" | awk -F\. '{print $2}')

if [ -z "${b_start}" ]; then
	echo "  Error, invalid IP start specified ('${ip_start}').
${usage}" 1>&2

	exit 55

fi

b_stop="${b_start}"


c_start=$(echo "${ip_start}" | awk -F\. '{print $3}')


if [ -n "${c_start}" ]; then
	c_stop="${c_start}"
else
	c_start="0"
	c_stop="254"
fi

d_start=$(echo "${ip_start}" | awk -F\. '{print $4}')

if [ -n "${d_start}" ]; then
	echo "  Error, invalid IP start specified ('${ip_start}').
${usage}" 1>&2

	exit 60

fi

d_start="1"
d_stop="254"


if [ -z "${prefix}" ]; then
	prefix="${default_ip_start}"
fi

log_file="ip-scan.log"

trap 'echo "  (scan has been stopped by user)"; exit' INT

output_message()
{

	echo "$*" >> "${log_file}"
	echo "$*"

}

output_message "   Scanning all ICMP-responding IP addresses from ${a_start}.${b_start}.${c_start}.${d_start} to ${a_stop}.${b_stop}.${c_stop}.${d_stop} at $(date)"
output_message

# a and b not to change:
a="${a_start}"
b="${b_start}"


c="${c_start}"
d="${d_start}"


while [ ${c} -le ${c_stop} ]; do

	echo " - exploring range ${a}.${b}.${c}.${d}-${d_stop}"

	while [ ${d} -le ${d_stop} ]; do
		target="${a}.${b}.${c}.${d}"
		#echo "Testing ${target}"
		if ping "${target}" -c 1 1>/dev/null; then
			output_message "++++ Found ${target}!!!!!"
		else
			[ $verbose -eq 1 ] || output_message "  (nothing at ${target})"
		fi
		d=$(expr ${d} + 1)
	done


	c=$(expr ${c} + 1)
	d=1

done

output_message "End of search at $(date)"
