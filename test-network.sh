#!/bin/sh

usage="Usage: $(basename $0): diagnoses whether the various network basic facilities are functional. If not, checks them continuously, until all of them are back to normal."

if [ "$1" = "-h" ] || [ "$1" = "--help" ]; then

	echo "${usage}"

	exit

fi


if [ ! $# -eq 0 ]; then

	echo "  Error, no argument is expected.
${usage}" 1>&2

	exit 25

fi


already_failed=1


# Checks network connectivity based on IP here:
check_ip()
{

	if ping -c 2 ${reliable_internet_server_ip} 1>/dev/null 2>&1; then

		echo " - reliable internet server IP (${reliable_internet_server_ip}) responding, external network connectivity ok"

		if ping -c 2 ${reliable_internet_server_name} 1>/dev/null 2>&1; then

			echo " - reliable internet server DNS name (${reliable_internet_server_name}) responding, external DNS ok"

			is_good=0

			if [ $already_failed -eq 0 ]; then

				# Notify a bit loudly whenever the connectivity is restored:
				bong.sh
				echo "Internet connectivity restored!"
				bong.sh
				bong.sh

			else

				echo "Everything seems to be fine!"

			fi

		else

			echo "Reliable internet server DNS name (${reliable_internet_server_name}) not responding, external DNS ko?" 1>&2
			#exit 4

		fi

	else

		echo "Reliable internet server IP (${reliable_internet_server_ip}) not responding, no Internet connectivity?" 1>&2

	fi

}



# Now, if gateway_name is set, gateway_ip shall be set as well:

gateway_name="${GATEWAY}"

if [ -z "${gateway_name}" ]; then

	#echo "  Error, no gateway name set (GATEWAY environment variable)." 1>&2
	#exit 15

	#gateway_ip=192.168.0.10
	#gateway_ip=10.0.0.1

	#echo "Warning: no GATEWAY environment variable set, assuming ${gateway_ip}."

	echo "Warning: no GATEWAY environment variable set, assuming none used."
	gateway_ip=""

else

	# Risk of longer DNS time-out:
	host_cmd="$(which host 2>/dev/null)"

	if [ ! -x "${host_cmd}" ]; then

		echo "  Error, no 'host' executable available. On Arch, consider installing the 'bind' package." 1>&2
		exit 16

	fi

	gateway_ip="$(host ${gateway_name} 2>/dev/null | sed 's|.*address ||1')"

	if [ -z "${gateway_ip}" ]; then

		echo "  Error, no gateway IP available." 1>&2
		exit 17

	fi

fi


#reliable_internet_server_ip=72.14.207.99
#reliable_internet_server_ip=66.249.92.104

# Corresponds to google.com
reliable_internet_server_ip=8.8.8.8

reliable_internet_server_name=google.com

is_good=1

while [ $is_good -eq 1 ]; do

	echo
	echo "Checking current network status at $(date)..."

	if [ -n "${gateway_name}" ]; then

		# Hence gateway_ip is set:
		if ping -c 2 ${gateway_ip} 1>/dev/null 2>&1; then

			echo " - gateway IP (${gateway_ip}) responding, internal network connectivity ok"
			if ping -c 2 ${gateway_name} 1>/dev/null 2>&1; then

				echo " - gateway DNS name (${gateway_name}) responding, internal DNS ok"
				check_ip

			else

				echo "Gateway DNS name (${gateway_name}) not responding, internal DNS ko?" 1>&2
				#exit 2

			fi

		else

			echo "Gateway IP (${gateway_ip}) not responding, internal network connectivity ko? Possibly no known gateway, continuing checks..." 1>&2

			#echo "Pinging now continuously to know when network is back..."
			#ping ${gateway_ip}

			if ping -c 2 ${reliable_internet_server_ip} 1>/dev/null 2>&1; then

				echo " - reliable internet server IP (${reliable_internet_server_ip}) responding, external network connectivity ok"

				if ping -c 2 ${reliable_internet_server_name} 1>/dev/null 2>&1; then

					echo " - reliable internet server DNS name (${reliable_internet_server_name}) responding, external DNS ok"

					echo "Everything seems to be fine!"
					is_good=0

				else

					echo "Reliable internet server DNS name (${reliable_internet_server_name}) not responding, external DNS ko?" 1>&2
					#exit 4

				fi

			else

				echo "Reliable internet server IP (${reliable_internet_server_ip}) not responding, external network connectivity ko?" 1>&2
				#exit 3

			fi

			#exit 1

		fi

	else

		check_ip

	fi

	sleep 2
	already_failed=0

done
