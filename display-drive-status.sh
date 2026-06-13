#!/bin/sh

# Copyright (C) 2026-2026 Olivier Boudeville
#
# Author: Olivier Boudeville [olivier (dot) boudeville (at) esperide (dot) com]
#
# This file is part of the Ceylan-Hull toolbox (see http://hull.esperide.org).


usage="Usage: $(basename $0) [-h|--help] [-d|--detail]: checks and displays, possibly with details, the status of the local drives (hard drives / SSD SATA or NVME ones).

To be run as root.

Will rely on the 'nvme' command if available (which is provided on Arch by the 'nvme-cli' package; 'jq' then being needed as well)."

if [ "$1" = "-h" ] || [ "$1" = "--help" ]; then

	echo "${usage}"
	exit

fi

detail=1

if [ "$1" = "-d" ] || [ "$1" = "--detail" ]; then

	detail=0
	shift

fi

if [ ! $# -eq 0 ]; then

	echo "  Error, extra parameter(s) specified.
${usage}" 1>&2

	exit 5

fi


if [ ! $(id -u) -eq 0 ]; then

	echo "  Error, you must be root.
${usage}" 1>&2
	exit 6

fi



#printf "All local drive-like devices found are:\n$(lsblk -ndo NAME,TYPE | awk '$2=="disk"{print "/dev/"$1}')\n\n"

hdds=""
ssd_satas=""
ssd_nvmes=""

echo "Listing the local drive-like devices found:"

for d in $(lsblk -ndo NAME); do

    rota=$(cat /sys/block/$d/queue/rotational)
    tran=$(cat /sys/block/$d/device/transport 2>/dev/null)

    #if [ "$tran" = "nvme" ]; then
    if [ "$tran" = "pcie" ]; then
		ssd_nvmes="${ssd_nvmes} $d"
    elif [ "$rota" = "0" ]; then
		ssd_satas="${ssd_satas} $d"
    else
		hdds="${hdds} $d"
    fi

done


# No leading space wanted before variable:

if [ -n "${hdds}" ]; then

	echo " - HDD:${hdds}"

else

	echo " - no HDD found"

fi


if [ -n "${ssd_satas}" ]; then

	echo " - SSD SATA:${ssd_satas}"

else

	echo " - no SSD SATA found"

fi


if [ -n "${ssd_nvmes}" ]; then

	echo " - SSD NVME:${ssd_nvmes}"

else

	echo " - no SSD NVME found"

fi

echo


needed_for_smartctl="${hdds} ${ssd_satas}"

use_nvme=1

if [ -n "${ssd_nvmes}" ]; then

	nvme_exec="$(which nvme 2>/dev/null)"

	if [ -x "${nvme_exec}" ]; then

		jq_exec="$(which jq 2>/dev/null)"

		if [ -x "${jq_exec}" ]; then

			use_nvme=0

		else

			echo "(warning: no 'jq' executable found, no precise diagnostics will be available; install it on Arch thanks to the 'jq' package)" 1>&2

			needed_for_smartctl="${needed_for_smartctl} ${ssd_nvmes}"

		fi

	else

		echo "(warning: no 'nwme' executable found, diagnostics will be less precise; install it on Arch thanks to the 'nvme-cli' package)" 1>&2

		needed_for_smartctl="${needed_for_smartctl} ${ssd_nvmes}"

	fi

fi



if [ -n "${needed_for_smartctl}" ]; then

	smartctl_exec="$(which smartctl 2>/dev/null)"

	if [ ! -x "${smartctl_exec}" ]; then

		echo "  Error, no 'smartctl' executable found. Install it on Arch thanks to the 'smartmontools' package." 1>&2

		exit 15

	fi

fi


for d in ${hdds}; do

    echo "=== For hard drive $d:"

	#"${smartctl_exec}" -A "/dev/$d" | grep -E -i "WHEN_FAILED|temp|wear|health|percent|life"
	diag="$(${smartctl_exec} -A "/dev/$d")"

	[ $detail -eq 1 ] || echo "HDD diagnosis: ${diag}
"

	# if Reallocated_Event_Count is non-null, degradation started:
	realloc="$(printf '%s\n' "${diag}" | grep Reallocated_Event_Count | cut -w -f10)"

	if [ ! "${realloc}" = "0" ]; then

		echo "Warning: reallocated (i.e. faulty) sectors detected (${realloc}), degradation started." 1>&2

	else

		echo "(no faulty sectors detected)"

	fi

	echo
done


for d in ${ssd_satas}; do

    echo "=== For SATA SSD drive $d:"

	diag="$(${smartctl_exec} -A "/dev/$d")"

	[ $detail -eq 1 ] || echo "SATA SSD diagnosis: ${diag}"

done

if [ -n "${ssd_nvmes}" ]; then

	if [ $use_nvme -eq 0 ]; then

		for d in ${ssd_nvmes}; do

			echo "=== For NVME SSD drive $d:"

			diag="$("${nvme_exec}" smart-log -o json "/dev/$d")"

			[ $detail -eq 1 ] || echo "NVME SSD diagnosis: ${diag}"

			temp_str="$(echo "${diag}" | "${jq_exec}" .temperature)"
			temp_c_str="$(echo "($((temp_str)) - 273.15 + 0.5) / 1" | bc)"
			echo "Current temperature: ${temp_c_str}°C"

			# if percentage_used is non-null, degradation started:
			#p_used="$(printf '%s\n' "${diag}" | grep percentage_used | cut -w -f3)"
			#p_used="$(printf '%s\n' "${diag}" | grep percentage_used | cut -w -f3)"
			p_used="$(echo "${diag}" | "${jq_exec}" .percent_used)"

			#if [ "${p_used}" = "0%" ]; then
			if [ "${p_used}" = "0" ]; then

				echo "(null used percentage reported, no degradation detected)"

			else

				echo "Warning: non-null used percentage reported (${p_used}%), NVME degradation detected." 1>&2

			fi

			# available_spare must be higher than available_spare_threshold; for
			# example:
			#
			#available_spare				: 100%
			#available_spare_threshold		: 10%

			avail_spare_str="$(echo "${diag}" | "${jq_exec}" .avail_spare)"
			avail_spare_t_str="$(echo "${diag}" | "${jq_exec}" .spare_thresh)"

			#echo "available_spare = ${avail_spare_str}, available_spare_threshold=${avail_spare_t_str}"

			avail_spare=$((${avail_spare_str}))
			avail_spare_t=$((${avail_spare_t_str}))

			if [ $avail_spare -lt $avail_spare_t ]; then

				echo "Alert: available spare (${avail_spare}%) dropped below the low threshold (${avail_spare_t}, this NVME is close to critical condition." 1>&2

			else

				if [ $avail_spare -lt 100 ]; then

					echo "Warning: non-optimal available spare (${avail_spare}%, instead of 100%; low threshold (${avail_spare_t}%) not reached yet." 1>&2

				else

					echo "(ideal 100% spare level; low threshold: ${avail_spare_t}%)"

				fi

			fi


			critical_warning_str="$(echo "${diag}" | "${jq_exec}" .critical_warning)"

			if [ ${critical_warning_str} = "0" ]; then

				echo "(no critical warning reported)"

			else

				echo "Alert: ${critical_warning_str} code reported for critical warning." 1>&2

			fi


			media_errors_str="$(echo "${diag}" | "${jq_exec}" .media_errors)"

			if [ ${media_errors_str} = "0" ]; then

				echo "(no media error reported)"

			else

				echo "Alert: ${media_errors_str} media errors reported." 1>&2

			fi



			# Generally verbose and not that useful:
			#[ $detail -eq 1 ] || "${nvme_exec}" error-log "/dev/$d"
			#[ $detail -eq 1 ] || "${nvme_exec}" id-ctrl "/dev/$d"
		done

	else

		for d in ${ssd_nvmes}; do

			echo "=== For NVME SSD drive $d (fallback):"

			diag="$("${smartctl_exec}" -A "/dev/$d" | grep -E -i "WHEN_FAILED|temp|wear|health|percent|life")"

			[ $detail -eq 1 ] || echo "NVME SSD diagnosis: ${diag}"

			echo
		done

	fi

fi
