#!/bin/sh

# Copyright (C) 2026-2026 Olivier Boudeville
#
# Author: Olivier Boudeville [olivier (dot) boudeville (at) esperide (dot) com]
#
# This file is part of the Ceylan-Hull toolbox (see http://hull.esperide.org).

fail_exit_code=1

usage="Usage: $(basename $0): checks whether the DNS servers declared in the dnsmasq configuration seem usable (i.e. available and functional).

Returns a failure code (${fail_exit_code}) iff at least one configured DNS server was not found usable.

DNS over a ciphered connection may also be of interest.
"

if [ "$1" = "-h" ] || [ "$1" = "--help" ]; then

	echo "${usage}"

	exit

fi


if [ ! $# -eq 0 ]; then

	echo "  Error, no argument is expected.
${usage}" 1>&2

	exit 25

fi


dig_exec="$(which dig 2>/dev/null)"

if [ ! -x "${dig_exec}" ]; then

	echo "  Error, no 'dig' executable found.
${usage}" 1>&2

	exit 35

fi



main_conf_file="/etc/dnsmasq.conf"

# The files to check are dnsmasq.conf and the ones included thanks to
# 'conf-file=' ('conf-dir=' could be managed as well):
#
conf_files="${main_conf_file} $(grep -E '^conf-file=' ${main_conf_file} | cut -d= -f2 | tr -d '"' | tr -d "'")"

printf "  Extracting the DNS servers from the following detected dnsmasq configuration files: ${conf_files}\n\n"

dns_servers="$(grep -h -E '^[[:space:]]*server=' $conf_files \
          | sed -E 's/.*server=//' \
          | sed -E 's|/.*$||' \
          | sed -E 's/#.*//' \
          | sed -E 's/[[:space:]]+$//' \
          | grep -E '^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$' \
          | sort -u)"

#printf "  Testing the detected DNS servers:\n${dns_servers}\n"
printf "  Testing each detected DNS server:\n"

exit_code=0

for s in $dns_servers; do

	# Getting the Reverse DNS for that nameserver:
	#s_name="$("${dig_exec}" -x $s 2>/dev/null)"

	s_desc="name not resolvable"

	res="$("${dig_exec}" -x $s 2>/dev/null)"

	if [ $? -eq 0 ]; then

		s_name="${res}"
		s_desc="resolved as ${s_name}"

	fi

	# Try resolving an example host with this server:
    if "${dig_exec}" @"$s" example.com +time=2 +tries=1 1>/dev/null 2>&1; then

		printf " - $s (${s_desc}): functional\n"

	else

		printf " - $s (${s_desc}): FAILED (time-out or error)\n" 1>&2
		exit_code=${fail_exit_code}

	fi

done

if [ ${exit_code} -eq 1 ]; then
	printf "Error, at least one nameserver found unavailable." 1>&2
fi

exit ${exit_code}
