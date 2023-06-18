#!/bin/sh

usage="Usage: $(basename $0) [-h|--help] TARGET_DOMAIN: lists at least most of the DNS records of the specified domain."

if [ "$1" = "-h" ] || [ "$1" = "--help" ]; then

	echo "${usage}"
	exit 0

fi


if [ ! $# -eq 1 ]; then

	echo "  Error, exactly one parameter expected.
${usage}" 1>&2

	exit 5

fi


drill="$(which drill 2>/dev/null)"

if [ ! -x "${drill}" ]; then

	echo "  Error, the 'drill' executable is not available." 1>&2
	exit 10

fi


target_domain="$1"

echo "  Listing records for DNS domain '${target_domain}':"

# See https://en.wikipedia.org/wiki/List_of_DNS_record_types#Resource_records
# for further details.

base_records="A AAAA NS CNAME SOA TXT MX PTR WKS"

extra_records="AFSDB HINFO MINFO RP SIG KEY LOC"

# Bound to fail (require specified permissions):
specific_records="AXFR"

#all_records="${base_records} ${extra_records} ${specific_records}"
all_records="${base_records} ${extra_records}"

# Poor man's solution:
(for r in ${all_records}; do ${drill} "${target_domain}" $r | grep -v ';;' | grep "${target_domain}"; done) | sort -k 4 | uniq
