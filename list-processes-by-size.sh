#!/bin/sh

max_process_count=15


# The right metric:
rss_mem_type=0
rss_mem_name="resident"
rss_mem_code="rss"
rss_mem_opt="--${rss_mem_code}"


# May be misleading:
vsz_mem_type=1
vsz_mem_name="virtual"
vsz_mem_code="vsz"
vsz_mem_opt="--${vsz_mem_code}"


# Defaults:
mem_type=${rss_mem_type}
mem_name=${rss_mem_name}
mem_code=${rss_mem_code}


usage="Usage: $(basename $0) [${rss_mem_opt}|${vsz_mem_opt}]: lists the up to ${max_process_count} processes that are the largest in memory (default: in ${rss_mem_code} size, which is generally the right metric), by decreasing sizes. Use the --${vsz_mem_code} option to switch to the ${vsz_mem_name} size instead."


if [ "$1" = "--rss" ] ; then

	mem_type=${rss_mem_type}
	mem_name=${rss_mem_name}
	mem_code=${rss_mem_code}

	shift

elif [ "$1" = "--vsz" ] ; then

	mem_type=${vsz_mem_type}
	mem_name=${vsz_mem_name}
	mem_code=${vsz_mem_code}

	shift

elif [ -n "$1" ] ; then

	echo "Unexpected parameter: $1.
$usage" 1>&2
	exit 10

fi


# Sizes are expressed in kilobytes.

# Ex:
# $ list-processes-by-size.sh
#	Listing running processes by decreasing virtual size in RAM (total size in KiB):
#    PID    VSZ COMMAND
#	420080 42789072 XXXX
# ...

# See also: atop -m


if [ ! $# -eq 0 ]; then

	echo " Error, too many parameters used.
${usage}" 1>&2

	exit 10

fi


echo -e "\tListing running processes by decreasing ${mem_name} size in RAM (total size in KiB): "
#echo "(see also: atop -m)"

#--no-headers
ps -e -o pid,${mem_code},args --sort -${mem_code} | head -n ${max_process_count}
