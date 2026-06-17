#!/bin/sh

# Copyright (C) 2026-2026 Olivier Boudeville
#
# Author: Olivier Boudeville [olivier (dot) boudeville (at) esperide (dot) com]
#
# This file is part of the Ceylan-Hull toolbox (see http://hull.esperide.org).


normal_code=0
warning_code=1
error_code=2


# Default:
exit_code=${normal_code}


function set_warning()
{

	if [ $exit_code -lt ${warning_code} ]; then

		exit_code=${warning_code}

	fi

}


function set_error()
{

	if [ $exit_code -lt ${error_code} ]; then

		exit_code=${error_code}

	fi

}



function diagnose_disk()
{

	diag="$1"

	temp="$(printf '%s\n' "${diag}" | grep Airflow_Temperature_Cel | awk '{printf $10}')"
	if [ -n "${temp}" ]; then
		echo " - current temperature: ${temp}°C"
	fi

	power_on_time_h="$(printf '%s\n' "${diag}" | grep Power_On_Hours | awk '{printf $10}')"
	if [ -n "${power_on_time_h}" ]; then
		power_on_time_d="$(echo "${power_on_time_h} / 24" | "${bc_exec}")"
		echo " - used for ${power_on_time_d} days"
	fi

	power_cycles="$(printf '%s\n' "${diag}" | grep Power_Cycle_Count | awk '{printf $10}')"
	if [ -n "${power_cycles}" ]; then
		echo " - ${power_cycles} start/stop power cycles done"
	fi


	ecc_rate="$(printf '%s\n' "${diag}" | grep ECC_Error_Rate | awk '{printf $10}')"

	if [ -n "${ecc_rate}" ]; then

		if [ "${ecc_rate}" = "0" ]; then

			[ $report_ok -eq 1 ] || echo "(null ECC error rate)"

		else

			echo "Warning: an ECC error rate of ${ecc_rate} has been detected, degradation started." 1>&2

			set_warning

		fi

	fi


	crc_count="$(printf '%s\n' "${diag}" | grep CRC_Error_Count | awk '{printf $10}')"

	if [ -n "${crc_count}" ]; then

		if [ "${crc_count}" = "0" ]; then

			[ $report_ok -eq 1 ] || echo "(null CRC error rate)"

		else

			echo "Warning: ${crc_count} CRC errors have been detected, degradation started." 1>&2

			set_warning

		fi

	fi


	pqr_count="$(printf '%s\n' "${diag}" | grep POR_Recovery_Count | awk '{printf $10}')"

	if [ -n "${pqr_count}" ]; then

		if [ "${pqr_count}" = "0" ]; then

			[ $report_ok -eq 1 ] || echo "(no PQR recovery reported)"

		else

			echo "Warning: ${pqr_count} recoveries have been detected, degradation started." 1>&2

			set_warning

		fi

	fi

	# If Reallocated_Event_Count is non-null, degradation started:
	realloc="$(printf '%s\n' "${diag}" | grep Reallocated_Event_Count | awk '{printf $10}')"

	if [ -n "${realloc}" ]; then

		if [ ! "${realloc}" = "0" ]; then

			echo "Warning: reallocated (i.e. faulty) sectors detected (${realloc}), sign of an aging/dying disk." 1>&2

			set_warning

		else

			[ $report_ok -eq 1 ] || echo "(no faulty sectors detected)"

		fi

	fi


	pending_sect="$(printf '%s\n' "${diag}" | grep Current_Pending_Sector | awk '{printf $10}')"

	if [ -n "${pending_sect}" ]; then

		# May not be returned:
		if [ ! "${pending_sect}" = "0" ]; then

			echo "Error: ${pending_sect} pending sectors reported, this disk is failing." 1>&2

			set_error

		else

			[ $report_ok -eq 1 ] || echo "(no pending sector reported)"

		fi

	fi


	off_uncor="$(printf '%s\n' "${diag}" | grep Offline_Uncorrectable | awk '{printf $10}')"

	# May not be returned:
	if [ -n "${off_uncor}" ]; then

		if [ ! "${off_uncor}" = "0" ]; then

			echo "Error: ${off_uncor} uncorrectable offline errors reported, this disk is failing." 1>&2

			set_error

		else

			[ $report_ok -eq 1 ] || echo "(no uncorrectable offline error reported)"

		fi

	fi


	wear_count="$(printf '%s\n' "${diag}" | grep Wear_Leveling_Count | awk '{printf $10}')"

	if [ -n "${wear_count}" ]; then

		if [ ! "${wear_count}" = "0" ]; then

			# Average number of erasure cycles ofthe NAND cells:
			echo "Warning: ${wear_count} wear leveling detected." 1>&2

			set_warning

		else

			[ $report_ok -eq 1 ] || echo "(null wear leveling detected)"

		fi

	fi


	# 0 is worn-out, 100 is new (Intel, Micron).
	media_w="$(printf '%s\n' "${diag}" | grep Media_Wearout_Indicator | awk '{printf $10}')"

	if [ -n "${media_w}" ]; then

		if [ ! "${media_w}" = "100" ]; then

			echo "Warning: non-ideal media wearout indicator (${media_w}) reported." 1>&2

			set_warning

		else

			[ $report_ok -eq 1 ] || echo "(no media wearout reported)"

		fi

	fi


	rsv_total="$(printf '%s\n' "${diag}" | grep Used_Rsvd_Blk_Cnt_Tot | awk '{printf $10}')"

	if [ -n "${rsv_total}" ]; then

		if [ ! "${rsv_total}" = "0" ]; then

			echo "Warning: ${rsv_total} reserved block used, degradation started." 1>&2

			set_warning

		else

			[ $report_ok -eq 1 ] || echo "(no reserved block used)"

		fi

	fi


	prog_failed="$(printf '%s\n' "${diag}" | grep Program_Fail_Cnt_Total | awk '{printf $10}')"

	if [ -n "${prog_failed}" ]; then

		if [ ! "${prog_failed}" = "0" ]; then

			echo "Warning: ${prog_failed} program failed, degradation started." 1>&2

			set_warning

		else

			[ $report_ok -eq 1 ] || echo "(no program failure)"

		fi

	fi


	erase_failed="$(printf '%s\n' "${diag}" | grep Erase_Fail_Count_Total | awk '{printf $10}')"

	if [ -n "${erase_failed}" ]; then

		if [ ! "${erase_failed}" = "0" ]; then

			echo "Warning: ${erase_failed} erase failed, degradation started." 1>&2

			set_warning

		else

			[ $report_ok -eq 1 ] || echo "(no erase failure)"

		fi

	fi


	bad_blocks="$(printf '%s\n' "${diag}" | grep Runtime_Bad_Block | awk '{printf $10}')"

	if [ -n "${bad_blocks}" ]; then

		if [ ! "${bad_blocks}" = "0" ]; then

			echo "Warning: ${bad_blocks} bad blocks detected at runtime, degradation started." 1>&2

			set_warning

		else

			[ $report_ok -eq 1 ] || echo "(no bad block detected at runtime)"

		fi

	fi


	uncor_errs="$(printf '%s\n' "${diag}" | grep Uncorrectable_Error_Cnt | awk '{printf $10}')"

	if [ -n "${uncor_errs}" ]; then

		if [ ! "${uncor_errs}" = "0" ]; then

			echo "Warning: ${uncor_errs} uncorrected errors detected, degradation started." 1>&2

			set_warning

		else

			[ $report_ok -eq 1 ] || echo "(no uncorrected errors detected)"

		fi

	fi


	echo

}



usage="Usage: $(basename $0) [-h|--help] [-ok|--report-ok] [-d|--detail] [DEVICE_NAME]: checks and displays the status of any specified disk-like device (hard drive, SSD SATA or NVME one), otherwise of all local ones.

Options:
  -ok | --report-ok: report also successful tests (not only warning/error conditions)
  -d  | --detail: display also the raw output collected for each disk

For example: $(basename $0) -ok sdb

To be run as root.

The return codes that are specific to issues of this script are higher or equal to 10, whereas the following ones help detecting disk-related problems:
 - ${normal_code}: no problematic information found about any disk
 - ${warning_code}: a warning has been issued about at least one disk
 - ${error_code}: a serious problem has been reported about at least one disk

Requires the 'jq' executable (provided on Arch by the 'jq' package).

Will rely on the 'nvme' command if available (which is provided on Arch by the 'nvme-cli' package)."


if [ "$1" = "-h" ] || [ "$1" = "--help" ]; then

	echo "${usage}"
	exit

fi


report_ok=1

if [ "$1" = "-ok" ] || [ "$1" = "--report-ok" ]; then

	report_ok=0
	shift

fi


detail=1

if [ "$1" = "-d" ] || [ "$1" = "--detail" ]; then

	detail=0
	shift

fi


if [ -n "$1" ]; then

	target_devices="$1"
	shift

	if [ ! -e "/dev/${target_devices}" ]; then

		echo "  Error, the specified device, '/dev/${target_devices}', does not exist." 1>&2

		exit 30

	fi

fi


if [ ! $# -eq 0 ]; then

	echo "  Error, extra parameter(s) specified.
${usage}" 1>&2

	exit 10

fi


if [ ! $(id -u) -eq 0 ]; then

	echo "  Error, you must be root.
${usage}" 1>&2
	exit 11

fi



jq_exec="$(which jq 2>/dev/null)"

if [ ! -x "${jq_exec}" ]; then

	echo "  Error, no 'jq' executable found. On Arch, install the 'jq' package." 1>&2

	exit 12

fi


bc_exec="$(which bc 2>/dev/null)"

if [ ! -x "${bc_exec}" ]; then

	echo "  Error, no 'bc' executable found. On Arch, install the 'bc' package." 1>&2

	exit 13

fi



exit_code=0


#printf "All local drive-like devices found are:\n$(lsblk -ndo NAME,TYPE | awk '$2=="disk"{print "/dev/"$1}')\n\n"

hdds=""
ssd_satas=""
ssd_nvmes=""

all_disks=1

if [ -z "${target_devices}" ]; then

	all_disks=0

	echo "Listing the local drive-like devices found:"
	target_devices="$(lsblk -ndo NAME)"

fi

for d in ${target_devices}; do

    rota="$(cat /sys/block/$d/queue/rotational 2>/dev/null)"
    tran="$(cat /sys/block/$d/device/transport 2>/dev/null)"

    #if [ "$tran" = "nvme" ]; then
    if [ "$tran" = "pcie" ]; then
		ssd_nvmes="${ssd_nvmes} $d"
    elif [ "$rota" = "0" ]; then
		ssd_satas="${ssd_satas} $d"
    else
		hdds="${hdds} $d"
    fi

done


if [ $all_disks -eq 0 ]; then

	# No leading space wanted before variables:

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

fi



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



needed_for_smartctl="${hdds} ${ssd_satas}"

use_nvme=1

if [ -n "${ssd_nvmes}" ]; then

	nvme_exec="$(which nvme 2>/dev/null)"

	if [ -x "${nvme_exec}" ]; then

		use_nvme=0

	else

		[ $report_ok -eq 1 ] || echo "(warning: no 'nwme' executable found, diagnostics will be less precise; install it on Arch thanks to the 'nvme-cli' package)" 1>&2

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
	diag="$("${smartctl_exec}" -A "/dev/$d")"
	res=$?

	[ $detail -eq 1 ] || echo "HDD diagnosis: ${diag}
"

	# Short of knowing a way to collect both the command exit code and its
	# standard output:
	#
	if [ ! ${res} -eq 0 ]; then

		echo "Warning: not able to collect information about /dev/$d, ignoring it.
" 1>&2

	else

		diagnose_disk "${diag}"

	fi

done


for d in ${ssd_satas}; do

    echo "=== For SATA SSD drive $d:"

	diag="$("${smartctl_exec}" -A "/dev/$d")"
	res=$?

	[ $detail -eq 1 ] || echo "SATA SSD diagnosis: ${diag}"

	# Short of knowing a way to collect both the command exit code and its
	# standard output:
	#
	if [ ! ${res} -eq 0 ]; then

		echo "Warning: not able to collect information about /dev/$d, ignoring it.
" 1>&2

	else

		diagnose_disk "${diag}"

	fi

done



if [ -n "${ssd_nvmes}" ]; then

	if [ $use_nvme -eq 0 ]; then

		for d in ${ssd_nvmes}; do

			echo "=== For NVME SSD drive $d:"

			diag="$("${nvme_exec}" smart-log -o json "/dev/$d")"

			[ $detail -eq 1 ] || echo "NVME SSD diagnosis: ${diag}"

			temp_str="$(echo "${diag}" | "${jq_exec}" .temperature)"
			temp_c_str="$(echo "(${temp_str} - 273.15 + 0.5) / 1" | ${bc_exec})"
			echo " - current temperature: ${temp_c_str}°C"

			power_on_time_str="$(echo "${diag}" | "${jq_exec}" .power_on_hours)"
			power_cycles="$(echo "${diag}" | "${jq_exec}" .power_cycles)"
			unsafe_shutdowns="$(echo "${diag}" | "${jq_exec}" ${nvme_prefix}.unsafe_shutdowns)"

			# Apparently, either since last start or overall:
			echo " - usage duration: $(echo "${power_on_time_str} / 24" | ${bc_exec}) days (overall: ${power_cycles} power cycles, with ${unsafe_shutdowns} unsafe shutdowns)"


			warning_temp_time_str="$(echo "${diag}" | "${jq_exec}" .warning_temp_time)"

			if [ -n "${warning_temp_time_str}" ] && [ "${warning_temp_time_str}" != "null" ] ; then

				if [ "${warning_temp_time_str}" = "0" ]; then
					[ $report_ok -eq 1 ] || echo "(no period beyond warning temperature logged)"
				else
				   echo " - duration beyond warning temperature: ${warning_temp_time_str} minutes"
				fi

			fi


			critical_temp_time_str="$(echo "${diag}" | "${jq_exec}" .critical_temp_time)"

			if [ -n "${critical_temp_time_str}" ] && [ "${critical_temp_time_str}" != "null" ]; then

				if [ "${critical_temp_time_str}" = "0" ]; then
					[ $report_ok -eq 1 ] || echo "(no period beyond critical temperature logged)"
				else
					echo " - logged duration beyond critical temperature: ${critical_temp_time_str} minutes"
				fi

			fi


			critical_comp_time_str="$(echo "${diag}" | "${jq_exec}" .critical_comp_time)"

			if [ -n "${critical_comp_time_str}" ] && [ "${critical_comp_time_str}" != "null" ]; then
				if [ "${critical_comp_time_str}" = "0" ]; then
					[ $report_ok -eq 1 ] || echo "(no period beyond critical temperature logged)"
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

				[ $report_ok -eq 1 ] || echo "${p_used_correct_hint}"

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

					[ $report_ok -eq 1 ] || echo "(ideal 100% spare level; low threshold: ${avail_spare_t}%)"

				fi

			fi


			critical_warning_str="$(echo "${diag}" | "${jq_exec}" .critical_warning)"

			if [ "${critical_warning_str}" = "0" ]; then

				[ $report_ok -eq 1 ] || echo "${crit_w_correct_hint}"

			else

				echo "Alert: ${critical_warning_str} ${crit_w_problem_hint}." 1>&2

			fi


			media_errors_str="$(echo "${diag}" | "${jq_exec}" .media_errors)"

			if [ "${media_errors_str}" = "0" ]; then

				[ $report_ok -eq 1 ] || echo "${media_error_correct_hint}"

			else

				echo "Alert: ${media_errors_str} ${media_error_problem_hint}." 1>&2

			fi


			error_log_str="$(echo "${diag}" | "${jq_exec}" .num_err_log_entries)"

			if [ "${error_log_str}" = "0" ]; then

				[ $report_ok -eq 1 ] || echo "${error_log_correct_hint}"

			else

				echo "Alert: ${error_log_str} ${error_log_problem_hint}." 1>&2

			fi


			critical_end_grp_str="$(echo "${diag}" | "${jq_exec}" .endurance_grp_critical_warning_summary)"

			if [ "${critical_end_grp_str}" = "0" ]; then

				[ $report_ok -eq 1 ] || echo "${crit_end_grp_correct_hint}"

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

			echo " - usage duration: $(echo "${power_on_time_str} / 24" | ${bc_exec}) days (${power_cycles} power cycles, with ${unsafe_shutdowns} unsafe shutdowns)"

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

				[ $report_ok -eq 1 ] || echo "${p_used_correct_hint}"

			else

				echo "Warning: non-zero used percentage reported (${p_used}%), ${p_used_problem_hint}." 1>&2

			fi


			end_used="$(echo "${diag}" | "${jq_exec}" .endurance_used.current_percent)"

			if [ "${end_used}" = "0" ]; then

				[ $report_ok -eq 1 ] || echo "${end_used_correct_hint}"

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

					[ $report_ok -eq 1 ] || echo "(ideal 100% spare level; low threshold: ${avail_spare_t}%)"

				fi

			fi


			critical_warning_str="$(echo "${diag}" | "${jq_exec}" ${nvme_prefix}.critical_warning)"

			if [ "${critical_warning_str}" = "0" ]; then

				[ $report_ok -eq 1 ] || echo "${crit_w_correct_hint}"

			else

				echo "Alert: ${critical_warning_str} ${crit_w_problem_hint}." 1>&2

			fi


			media_error_str="$(echo "${diag}" | "${jq_exec}" ${nvme_prefix}.media_errors)"

			if [ "${media_error_str}" = "0" ]; then

				[ $report_ok -eq 1 ] || echo "${media_error_correct_hint}"

			else

				echo "Alert: ${media_error_str} ${media_error_problem_hint}." 1>&2

			fi


			error_log_str="$(echo "${diag}" | "${jq_exec}" ${nvme_prefix}.num_err_log_entries)"

			if [ "${error_log_str}" = "0" ]; then

				[ $report_ok -eq 1 ] || echo "${error_log_correct_hint}"

			else

				echo "Alert: ${error_log_str} ${error_log_problem_hint}." 1>&2

			fi

		done

	fi

fi

exit ${exit_code}
