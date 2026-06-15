#!/bin/sh

# Copyright (C) 2026-2026 Olivier Boudeville
#
# Author: Olivier Boudeville [olivier (dot) boudeville (at) esperide (dot) com]
#
# This file is part of the Ceylan-Hull toolbox (see http://hull.esperide.org).


usage="Usage: $(basename $0) [-h|--help] [-d|--detail]: checks and displays, possibly with details, the status of the local drives (hard drives / SSD SATA or NVME ones).

To be run as root.

Requires the 'jq' executable (provided on Arch by the 'jq' package).

Will rely on the 'nvme' command if available (which is provided on Arch by the 'nvme-cli' package)."

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



jq_exec="$(which jq 2>/dev/null)"

if [ ! -x "${jq_exec}" ]; then

	echo "  Error, no 'jq' executable found. On Arch, install the 'jq' package." 1>&2

	exit 7

fi


bc_exec="$(which bc 2>/dev/null)"

if [ ! -x "${bc_exec}" ]; then

	echo "  Error, no 'bc' executable found. On Arch, install the 'bc' package." 1>&2

	exit 8

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


end_used_correct_hint="(full endurance reported based on guaranteed Total Bytes Written, no degradation detected)"

end_used_problem_hint="reduced endurance detected, based on guaranteed Total Bytes Written; at 60-70%: beware; at 100%: end of guaranteed life"


crit_end_grp_correct_hint="(full group endurance reported)"
crit_end_grp_problem_hint="reduced group endurance detected"


p_used_correct_hint="(no NVME constructor-determined lifetime degradation: zero used percentage reported, perfect condition)"

p_used_problem_hint="NVME constructor-determined lifetime degradation detected; at 60-70%: beware; at 100%: end of life"


media_error_correct_hint="(no media error reported)"
media_error_problem_hint="media errors reported, this is worrying"

crit_w_correct_hint="(no critical warning reported)"
crit_w_problem_hint="code reported for critical warning"

# critical_warning
# Champ bitmask indiquant des alertes :

#     bit 0 : espace spare faible

#     bit 1 : température trop haute/basse

#     bit 2 : fiabilité dégradée

#     bit 3 : media read-only

#     bit 4 : backup volatile failed


error_log_correct_hint="(no error log reported)"
error_log_problem_hint=" error log entries reported"


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

		use_nvme=0

	else

		echo "(warning: no 'nwme' executable found, diagnostics will be less precise; install it on Arch thanks to the 'nvme-cli' package)" 1>&2

		# Fallback to smartctl for NVMEs as well:
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
			temp_c_str="$(echo "($((temp_str)) - 273.15 + 0.5) / 1" | ${bc_exec})"
			echo " - current temperature: ${temp_c_str}°C"

			power_on_time_str="$(echo "${diag}" | "${jq_exec}" .power_on_hours)"
			power_cycles="$(echo "${diag}" | "${jq_exec}" .power_cycles)"
			unsafe_shutdowns="$(echo "${diag}" | "${jq_exec}" ${nvme_prefix}.unsafe_shutdowns)"

			echo " - total usage duration: $(echo "${power_on_time_str} / 24" | ${bc_exec}) days (${power_cycles} power cycles, with ${unsafe_shutdowns} unsafe shutdowns)"


			warning_temp_time_str="$(echo "${diag}" | "${jq_exec}" .warning_temp_time)"

			if [ -n "${warning_temp_time_str}" ] && [ "${warning_temp_time_str}" != "null" ] ; then

				if [ "${warning_temp_time_str}" = "0" ]; then
					echo "(no period beyond warning temperature logged)"
				else
				   echo " - duration beyond warning temperature: ${warning_temp_time_str} minutes"
				fi

			fi


			critical_temp_time_str="$(echo "${diag}" | "${jq_exec}" .critical_temp_time)"

			if [ -n "${critical_temp_time_str}" ] && [ "${critical_temp_time_str}" != "null" ]; then

				if [ "${critical_temp_time_str}" = "0" ]; then
					echo "(no period beyond critical temperature logged)"
				else
					echo " - logged duration beyond critical temperature: ${critical_temp_time_str} minutes"
				fi

			fi


			critical_comp_time_str="$(echo "${diag}" | "${jq_exec}" .critical_comp_time)"

			if [ -n "${critical_comp_time_str}" ] && [ "${critical_comp_time_str}" != "null" ]; then
				if [ "${critical_comp_time_str}" = "0" ]; then
					echo "(no period beyond critical temperature logged)"
				else
					echo " - logged duration beyond critical temperature: ${critical_comp_time_str} minutes"
				fi

			fi

			# if percentage_used is non-null, degradation started:
			#p_used="$(printf '%s\n' "${diag}" | grep percentage_used | cut -w -f3)"
			#p_used="$(printf '%s\n' "${diag}" | grep percentage_used | cut -w -f3)"
			p_used="$(echo "${diag}" | "${jq_exec}" .percent_used)"

			#if [ "${p_used}" = "0%" ]; then
			if [ "${p_used}" = "0" ]; then

				echo "${p_used_correct_hint}"

			else

				echo "Warning: non-zero used percentage reported (${p_used}%), ${p_used_problem_hint}." 1>&2

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

			if [ "${critical_warning_str}" = "0" ]; then

				echo "${crit_w_correct_hint}"

			else

				echo "Alert: ${critical_warning_str} ${crit_w_problem_hint}." 1>&2

			fi


			media_errors_str="$(echo "${diag}" | "${jq_exec}" .media_errors)"

			if [ "${media_errors_str}" = "0" ]; then

				echo "${media_error_correct_hint}"

			else

				echo "Alert: ${media_errors_str} ${media_error_problem_hint}." 1>&2

			fi


			error_log_str="$(echo "${diag}" | "${jq_exec}" .num_err_log_entries)"

			if [ "${error_log_str}" = "0" ]; then

				echo "${error_log_correct_hint}"

			else

				echo "Alert: ${error_log_str} ${error_log_problem_hint}." 1>&2

			fi


			critical_end_grp_str="$(echo "${diag}" | "${jq_exec}" .endurance_grp_critical_warning_summary)"

			if [ "${critical_end_grp_str}" = "0" ]; then

				echo "${crit_end_grp_correct_hint}"

			else

				echo "Alert: ${crit_end_grp_problem_hint} (code ${crit_end_grp_str} reported)." 1>&2

			fi


			# Generally verbose, hard to parse and not that useful:
			#[ $detail -eq 1 ] || "${nvme_exec}" error-log "/dev/$d"

			# Only useful to interpret smart-log:
			#[ $detail -eq 1 ] || "${nvme_exec}" id-ctrl "/dev/$d"

		done

	else

		# Here 'nvme' is not available:

		nvme_prefix=".nvme_smart_health_information_log"

		for d in ${ssd_nvmes}; do

			echo "=== For NVME SSD drive $d (fallback):"

			diag="$("${smartctl_exec}" -A "/dev/$d" -j)"

			[ $detail -eq 1 ] || echo "NVME SSD fallback diagnosis: ${diag}"

			temp_str="$(echo "${diag}" | "${jq_exec}" .temperature.current)"
			echo " - current temperature: ${temp_str}°C"

			power_on_time_str="$(echo "${diag}" | "${jq_exec}" .power_on_time.hours)"
			power_cycles="$(echo "${diag}" | "${jq_exec}" .power_cycle_count)"
			unsafe_shutdowns="$(echo "${diag}" | "${jq_exec}" ${nvme_prefix}.unsafe_shutdowns)"

			echo " - total usage duration: $(echo "${power_on_time_str} / 24" | ${bc_exec}) days (${power_cycles} power cycles, with ${unsafe_shutdowns} unsafe shutdowns)"

			warning_temp_time_str="$(echo "${diag}" | "${jq_exec}" ${nvme_prefix}.warning_temp_time)"

			if [ -n "${warning_temp_time_str}" ]; then

				echo " - duration beyond warning temperature: ${warning_temp_time_str} minutes"

			fi



			critical_comp_time_str="$(echo "${diag}" | "${jq_exec}" ${nvme_prefix}.critical_comp_time)"

			if [ -n "${critical_comp_time_str}" ]; then

				echo " - duration beyond critical temperature: ${critical_comp_time_str} minutes"

			fi

			if [ -n "${critical_temp_time_str}" ]; then

				echo " - duration beyond critical temperature: ${critical_temp_time_str} minutes"

			fi


			p_used="$(echo "${diag}" | "${jq_exec}" ${nvme_prefix}.percentage_used)"

			if [ "${p_used}" = "0" ]; then

				echo "${p_used_correct_hint}"

			else

				echo "Warning: non-zero used percentage reported (${p_used}%), ${p_used_problem_hint}." 1>&2

			fi


			end_used="$(echo "${diag}" | "${jq_exec}" .endurance_used.current_percent)"

			if [ "${end_used}" = "0" ]; then

				echo "${end_used_correct_hint}"

			else

				echo "Warning: non-zero used endurance reported (${end_used}%), ${end_used_problem_hint}." 1>&2

			fi



			avail_spare_str="$(echo "${diag}" | "${jq_exec}" ${nvme_prefix}.available_spare)"
			avail_spare_t_str="$(echo "${diag}" | "${jq_exec}" ${nvme_prefix}.available_spare_threshold)"

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


			critical_warning_str="$(echo "${diag}" | "${jq_exec}" ${nvme_prefix}.critical_warning)"

			if [ "${critical_warning_str}" = "0" ]; then

				echo "${crit_w_correct_hint}"

			else

				echo "Alert: ${critical_warning_str} ${crit_w_problem_hint}." 1>&2

			fi


			media_error_str="$(echo "${diag}" | "${jq_exec}" ${nvme_prefix}.media_errors)"

			if [ "${media_error_str}" = "0" ]; then

				echo "${media_error_correct_hint}"

			else

				echo "Alert: ${media_error_str} ${media_error_problem_hint}." 1>&2

			fi


			error_log_str="$(echo "${diag}" | "${jq_exec}" ${nvme_prefix}.num_err_log_entries)"

			if [ "${error_log_str}" = "0" ]; then

				echo "${error_log_correct_hint}"

			else

				echo "Alert: ${error_log_str} ${error_log_problem_hint}." 1>&2

			fi

		done

	fi

fi
