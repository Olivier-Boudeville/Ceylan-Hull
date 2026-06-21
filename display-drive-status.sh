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


function report()
{

	message="$1"

	# No non-error outputs when run by cron:
	if [ $cron -eq 1 ]; then
		echo "${message}"
	fi

	if [ $log -eq 0 ]; then

		echo "${message}" 1>> "${log_file}"

	fi

}


function set_warning()
{

	message="$1"

	if [ -n "${message}" ]; then

		full_msg="Warning: $1"

		# No non-error outputs when run by cron:
		if [ $cron -eq 1 ]; then
			echo "${full_msg}" 1>&2
		fi

		if [ $log -eq 0 ]; then

			echo "${full_msg}" 1>> "${log_file}"

		fi

	fi

	if [ $exit_code -lt ${warning_code} ]; then

		exit_code=${warning_code}

	fi

}


function set_error()
{

	message="$1"

	if [ -n "${message}" ]; then

		full_msg="Error: ${message}"

		echo "${full_msg}" 1>&2

		if [ $log -eq 0 ]; then

			echo "${full_msg}" 1>> "${log_file}"

		fi

	fi

	if [ $exit_code -lt ${error_code} ]; then

		exit_code=${error_code}

	fi

}


function hours_to_str()
{

	res=""

	hours="$1"

	days="$(echo "$hours / 24" | ${bc_exec})"

	if [ "${days}" != "0" ]; then

		years="$(echo "${days} / 365" | ${bc_exec})"

		if [ "${years}" = "0" ]; then

			res="${days} days"

		else

			remain_days="$(echo "${days} % 365" | ${bc_exec})"
			res="${years} years and ${remain_days} days"

			# Hours useless here:
			return

		fi

	fi

	remain_hours="$(echo "${hours} % 24" | ${bc_exec})"

	if [ "${remain_hours}" = "0" ]; then

		if [ -z "${res}" ]; then

			res="(none)"

		fi

	else

		res="${res} and ${remain_hours} hours"

	fi

}


function diagnose_disk()
{

	diag="$1"

	temp="$(printf '%s\n' "${diag}" | grep Airflow_Temperature_Cel | awk '{printf $10}')"
	#echo "Diagnosed airflow temp: '${temp}'."
	if [ -n "${temp}" ]; then
		report " - current (airflow) temperature: ${temp}°C"
	fi

	temp="$(printf '%s\n' "${diag}" | grep Temperature_Celsius | awk '{printf $10}')"
	if [ -n "${temp}" ]; then
		report " - current temperature: ${temp}°C"
	fi

	power_on_time_h="$(printf '%s\n' "${diag}" | grep Power_On_Hours | awk '{printf $10}')"
	if [ -n "${power_on_time_h}" ]; then
		hours_to_str "${power_on_time_h}"
		report " - used for ${res}"
	fi

	power_cycles="$(printf '%s\n' "${diag}" | grep Power_Cycle_Count | awk '{printf $10}')"
	if [ -n "${power_cycles}" ]; then
		report " - ${power_cycles} power cycles done"
	fi

	# Often the same as previous:
	start_stop_count="$(printf '%s\n' "${diag}" | grep Start_Stop_Count | awk '{printf $10}')"
	if [ -n "${start_stop_count}" ]; then
		if [ "${start_stop_count}" != "${power_cycles}" ]; then
			report " - ${start_stop_count} start/stop operations done"
		fi
	fi

	ecc_rate="$(printf '%s\n' "${diag}" | grep ECC_Error_Rate | awk '{printf $10}')"

	if [ -n "${ecc_rate}" ]; then

		if [ "${ecc_rate}" = "0" ]; then

			[ $report_ok -eq 1 ] || report "(null ECC error rate)"

		else

			set_warning "an ECC error rate of ${ecc_rate} has been detected, degradation started."

		fi

	fi


	seek_rate="$(printf '%s\n' "${diag}" | grep Seek_Error_Rate | awk '{printf $10}')"

	if [ -n "${seek_rate}" ]; then

		if [ "${seek_rate}" = "0" ]; then

			[ $report_ok -eq 1 ] || report "(null seek error rate)"

		else

			set_warning "a seek error rate of ${seek_rate} has been detected, degradation started."

		fi

	fi


	spin_rate="$(printf '%s\n' "${diag}" | grep Spin_Retry_Count | awk '{printf $10}')"

	if [ -n "${spin_rate}" ]; then

		if [ "${spin_rate}" = "0" ]; then

			[ $report_ok -eq 1 ] || report "(null spin error rate)"

		else

			set_warning "a spin error rate of ${spin_rate} has been detected, degradation started."

		fi

	fi


	calibration_rate="$(printf '%s\n' "${diag}" | grep Calibration_Retry_Count | awk '{printf $10}')"

	if [ -n "${calibration_rate}" ]; then

		if [ "${calibration_rate}" = "0" ]; then

			[ $report_ok -eq 1 ] || report "(null calibration error rate)"

		else

			set_warning "a calibration error rate of ${calibration_rate} has been detected, degradation started."

		fi

	fi


	crc_count="$(printf '%s\n' "${diag}" | grep CRC_Error_Count | awk '{printf $10}')"

	if [ -n "${crc_count}" ]; then

		if [ "${crc_count}" = "0" ]; then

			[ $report_ok -eq 1 ] || report "(null CRC error rate)"

		else

			set_warning "${crc_count} CRC errors have been detected, degradation started."

		fi

	fi


	pqr_count="$(printf '%s\n' "${diag}" | grep POR_Recovery_Count | awk '{printf $10}')"

	if [ -n "${pqr_count}" ]; then

		if [ "${pqr_count}" = "0" ]; then

			[ $report_ok -eq 1 ] || report "(no PQR recovery reported)"

		else

			set_warning "${pqr_count} PQR recoveries have been detected, degradation started."

		fi

	fi

	# If Reallocated_Event_Count is non-null, degradation started:
	realloc="$(printf '%s\n' "${diag}" | grep Reallocated_Event_Count | awk '{printf $10}')"

	if [ -n "${realloc}" ]; then

		if [ ! "${realloc}" = "0" ]; then

			set_warning "${realloc} reallocation events reported (i.e. faulty sectors), sign of an aging/dying disk."

		else

			[ $report_ok -eq 1 ] || report "(no sector reallocation event detected)"

		fi

	fi


	realloc_sect="$(printf '%s\n' "${diag}" | grep Reallocated_Sector_Ct | awk '{printf $10}')"

	if [ -n "${realloc_sect}" ]; then

		if [ ! "${realloc_sect}" = "0" ]; then

			set_warning "${realloc} reallocated (faulty) sectors have been detected, sign of an aging/dying disk."

		else

			[ $report_ok -eq 1 ] || report "(no faulty sector detected)"

		fi

	fi


	pending_sect="$(printf '%s\n' "${diag}" | grep Current_Pending_Sector | awk '{printf $10}')"

	if [ -n "${pending_sect}" ]; then

		# May not be returned:
		if [ ! "${pending_sect}" = "0" ]; then

			set_error "${pending_sect} pending sectors reported, this disk is failing."

		else

			[ $report_ok -eq 1 ] || report "(no pending sector reported)"

		fi

	fi


	off_uncor="$(printf '%s\n' "${diag}" | grep Offline_Uncorrectable | awk '{printf $10}')"

	# May not be returned:
	if [ -n "${off_uncor}" ]; then

		if [ ! "${off_uncor}" = "0" ]; then

			set_error "${off_uncor} uncorrectable offline errors reported, this disk is failing."

		else

			[ $report_ok -eq 1 ] || report "(no uncorrectable offline error reported)"

		fi

	fi


	wear_count="$(printf '%s\n' "${diag}" | grep Wear_Leveling_Count | awk '{printf $10}')"

	if [ -n "${wear_count}" ]; then

		if [ ! "${wear_count}" = "0" ]; then

			set_warning "wear leveling detected (average number of erasure cycles of the NAND cells: ${wear_count})."

		else

			[ $report_ok -eq 1 ] || report "(null wear leveling detected)"

		fi

	fi


	# 0 is worn-out, 100 is new (Intel, Micron).
	media_w="$(printf '%s\n' "${diag}" | grep Media_Wearout_Indicator | awk '{printf $10}')"

	if [ -n "${media_w}" ]; then

		if [ ! "${media_w}" = "100" ]; then

			set_warning "non-ideal media wearout indicator (${media_w}) reported."

		else

			[ $report_ok -eq 1 ] || report "(no media wearout reported)"

		fi

	fi


	rsv_total="$(printf '%s\n' "${diag}" | grep Used_Rsvd_Blk_Cnt_Tot | awk '{printf $10}')"

	if [ -n "${rsv_total}" ]; then

		if [ ! "${rsv_total}" = "0" ]; then

			set_warning "${rsv_total} reserved block used, degradation started."

		else

			[ $report_ok -eq 1 ] || report "(no reserved block used)"

		fi

	fi


	prog_failed="$(printf '%s\n' "${diag}" | grep Program_Fail_Cnt_Total | awk '{printf $10}')"

	if [ -n "${prog_failed}" ]; then

		if [ ! "${prog_failed}" = "0" ]; then

			set_warning "${prog_failed} program failed, degradation started."

		else

			[ $report_ok -eq 1 ] || report "(no program failure)"

		fi

	fi


	erase_failed="$(printf '%s\n' "${diag}" | grep Erase_Fail_Count_Total | awk '{printf $10}')"

	if [ -n "${erase_failed}" ]; then

		if [ ! "${erase_failed}" = "0" ]; then

			set_warning "${erase_failed} erase failed, degradation started."

		else

			[ $report_ok -eq 1 ] || report "(no erase failure)"

		fi

	fi


	bad_blocks="$(printf '%s\n' "${diag}" | grep Runtime_Bad_Block | awk '{printf $10}')"

	if [ -n "${bad_blocks}" ]; then

		if [ ! "${bad_blocks}" = "0" ]; then

			set_warning  "${bad_blocks} bad blocks detected at runtime, degradation started."

		else

			[ $report_ok -eq 1 ] || report "(no bad block detected at runtime)"

		fi

	fi


	uncor_errs="$(printf '%s\n' "${diag}" | grep Uncorrectable_Error_Cnt | awk '{printf $10}')"

	if [ -n "${uncor_errs}" ]; then

		if [ ! "${uncor_errs}" = "0" ]; then

			set_warning "${uncor_errs} uncorrected errors detected, degradation started."

		else

			[ $report_ok -eq 1 ] || report "(no uncorrected errors detected)"

		fi

	fi


	raw_read="$(printf '%s\n' "${diag}" | grep Raw_Read_Error_Rate | awk '{printf $10}')"

	if [ -n "${raw_read}" ]; then

		if [ ! "${raw_read}" = "0" ]; then

			set_warning "a raw read error rate of ${raw_read} has been detected, degradation started."

		else

			[ $report_ok -eq 1 ] || report "(no raw read error rate reported)"

		fi

	fi

	# Blank line:
	report ""

}



function run_smartctl()
{

	disk="$1"

	# Either "" or "-j":
	opts="$2"

	diag="$("${smartctl_exec}" -A "/dev/$1" ${opts})"

	# Not 'res', otherwise colliding use:
	res_diag=$?

	#echo "${diag}"

	# Bit 1: Device open failed, device did not return an IDENTIFY DEVICE
	# structure, or device is in a low-power mode.
	#
	bit_1=$((${res_diag} & 1))

	if [ $bit_1 -eq 1 ]; then

		set_warning "not able to collect information about ${disk}, ignoring it.
"

	else

		diagnose_disk "${diag}"

	fi

	# printf 'DEBUG: res_diag="%s"\n' "$res_diag" >&2
	return ${res_diag}

}


# Defaults:

report_ok=1
detail=1

log=1
log_file="${HOME}/.$(date '+%Y%m%d')-drive-statuses-of-$(hostname -s).log"

cron=1



usage="Usage: $(basename $0) [-h|--help] [-ok|--report-ok] [-d|--detail] [-l|--log] [-c|--cron] [DEVICE_NAME]: checks and displays the status of any specified disk-like device (hard drive, SSD SATA or NVME one), otherwise of all local ones.

Options:
  -ok | --report-ok: report also successful tests (not only warning/error conditions)
  -d  | --detail: display also the raw output collected for each disk
  -l  | --log: log message in '${log_file}'
  -c  | --cron: set the 'crontab' mode, in which a per-month full diagnosis log file is recorded (e.g., here, in '${log_file}'), and outputs are made iff at least one warning or error has been detected; implies the --report-ok and --detail options

For example: $(basename $0) -ok sdb

To be run as root.

The return codes that are specific to issues of this script are higher or equal to 10, whereas the following ones help detecting disk-related problems:
 - ${normal_code}: no problematic information found about any disk
 - ${warning_code}: a warning has been issued about at least one disk
 - ${error_code}: a serious problem has been reported about at least one disk

Requires the 'jq' executable (provided on Arch by the 'jq' package).

Will rely on the 'nvme' command if available (which is provided on Arch by the 'nvme-cli' package).

Typical usage with cron is, for the root user:
# Every Monday at 4:13 AM, check and record the status of all local disks:
13  04   *   *  1 /usr/local/hull/display-drive-status.sh --cron
"


token_eaten=1


while [ ! $# -eq 0 ]; do


	if [ "$1" = "-h" ] || [ "$1" = "--help" ]; then

		echo "${usage}"
		exit

	fi


	if [ "$1" = "-ok" ] || [ "$1" = "--report-ok" ]; then

		report_ok=0
		shift
		token_eaten=0

	fi


	if [ "$1" = "-d" ] || [ "$1" = "--detail" ]; then

		detail=0
		shift
		token_eaten=0

	fi


	if [ "$1" = "-l" ] || [ "$1" = "--log" ]; then

		log=0
		shift
		token_eaten=0

	fi


	if [ "$1" = "-c" ] || [ "$1" = "--cron" ]; then

		report_ok=0
		detail=0
		cron=0
		log=0

		shift
		token_eaten=0

	fi


	if [ -n "$1" ]; then

		target_devices="$1"
		shift
		token_eaten=0

		if [ ! -e "/dev/${target_devices}" ]; then

			set_error "the specified device, '/dev/${target_devices}', does not exist.
${usage}"

			exit 30

		fi

	fi


	if [ $token_eaten -eq 1 ]; then

		echo "  Error, not able to interpret '$1'.
${usage}" 1>&2

		exit 35

	fi

done

if [ ! $# -eq 0 ]; then

	set_error "extra parameter(s) specified.
${usage}"

	exit 10

fi


if [ ! $(id -u) -eq 0 ]; then

	set_error "  Error, you must be root.
${usage}"
	exit 11

fi



jq_exec="$(which jq 2>/dev/null)"

if [ ! -x "${jq_exec}" ]; then

	set_error "no 'jq' executable found. On Arch, install the 'jq' package."

	exit 12

fi


bc_exec="$(which bc 2>/dev/null)"

if [ ! -x "${bc_exec}" ]; then

	set_error "no 'bc' executable found. On Arch, install the 'bc' package."

	exit 13

fi


if [ ${log} -eq 0 ]; then

	if [ -f "${log_file}" ]; then

		# Erases any past one:
		/bin/rm -f "${log_file}"

	fi

	echo "Script $(basename $0) registering disk-related logs on $(date)." > "${log_file}"

fi


exit_code=0


#printf "All local drive-like devices found are:\n$(lsblk -ndo NAME,TYPE | awk '$2=="disk"{print "/dev/"$1}')\n\n"

hdds=""
ssd_satas=""
ssd_nvmes=""

all_disks=1

if [ -z "${target_devices}" ]; then

	all_disks=0

	report "Listing the local drive-like devices found:"
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

		report " - HDD:${hdds}"

	else

		report " - no HDD found"

	fi


	if [ -n "${ssd_satas}" ]; then

		report " - SSD SATA:${ssd_satas}"

	else

		report " - no SSD SATA found"

	fi


	if [ -n "${ssd_nvmes}" ]; then

		report " - SSD NVME:${ssd_nvmes}"

	else

		report " - no SSD NVME found"

	fi

	report ""

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
error_log_problem_hint="error log entries reported"



needed_for_smartctl="${hdds} ${ssd_satas}"

use_nvme=1

if [ -n "${ssd_nvmes}" ]; then

	nvme_exec="$(which nvme 2>/dev/null)"

	if [ -x "${nvme_exec}" ]; then

		use_nvme=0

	else

		report "(warning: no 'nwme' executable found, diagnostics will be less precise; install it on Arch thanks to the 'nvme-cli' package)"

		# Fallback to smartctl for NVMEs as well:
		needed_for_smartctl="${needed_for_smartctl} ${ssd_nvmes}"

	fi

fi


if [ -n "${needed_for_smartctl}" ]; then

	smartctl_exec="$(which smartctl 2>/dev/null)"

	if [ ! -x "${smartctl_exec}" ]; then

		set_error "no 'smartctl' executable found. Install it on Arch thanks to the 'smartmontools' package."

		exit 15

	fi

fi


for d in ${hdds}; do

    report "=== For hard drive $d:"

	#"${smartctl_exec}" -A "/dev/$d" | grep -E -i "WHEN_FAILED|temp|wear|health|percent|life"

	# Sets 'diag':
	run_smartctl "$d"

	[ $detail -eq 1 ] || report "HDD diagnosis: ${diag}
"

done


for d in ${ssd_satas}; do

    report "=== For SATA SSD drive $d:"

	# Sets 'diag':
	run_smartctl "$d"

	[ $detail -eq 1 ] || report "SATA SSD diagnosis: ${diag}
"

done



if [ -n "${ssd_nvmes}" ]; then

	if [ $use_nvme -eq 0 ]; then

		for d in ${ssd_nvmes}; do

			report "=== For NVME SSD drive $d:"

			diag="$("${nvme_exec}" smart-log -o json "/dev/$d")"
			res=$?

			if [ ! $res -eq 0 ]; then

				set_error "failed running 'nvme' (${res})."

			fi

			[ $detail -eq 1 ] || report "NVME SSD diagnosis: ${diag}"

			temp_str="$(echo "${diag}" | "${jq_exec}" .temperature)"
			temp_c_str="$(echo "(${temp_str} - 273.15 + 0.5) / 1" | ${bc_exec})"
			report " - current temperature: ${temp_c_str}°C"

			power_on_time_str="$(echo "${diag}" | "${jq_exec}" .power_on_hours)"

			hours_to_str "${power_on_time_str}"

			power_cycles="$(echo "${diag}" | "${jq_exec}" .power_cycles)"
			unsafe_shutdowns="$(echo "${diag}" | "${jq_exec}" ${nvme_prefix}.unsafe_shutdowns)"

			# Apparently, either since last start or overall:

			report " - usage duration: ${res} (overall: ${power_cycles} power cycles, with ${unsafe_shutdowns} unsafe shutdowns)"


			warning_temp_time_str="$(echo "${diag}" | "${jq_exec}" .warning_temp_time)"

			if [ -n "${warning_temp_time_str}" ] && [ "${warning_temp_time_str}" != "null" ]; then

				if [ "${warning_temp_time_str}" = "0" ]; then
					[ $report_ok -eq 1 ] || report "(no period beyond warning temperature logged)"
				else
				   report " - duration beyond warning temperature: ${warning_temp_time_str} minutes"
				fi

			fi


			critical_temp_time_str="$(echo "${diag}" | "${jq_exec}" .critical_temp_time)"

			if [ -n "${critical_temp_time_str}" ] && [ "${critical_temp_time_str}" != "null" ]; then

				if [ "${critical_temp_time_str}" = "0" ]; then
					[ $report_ok -eq 1 ] || report "(no period beyond critical temperature logged)"
				else
					report " - logged duration beyond critical temperature: ${critical_temp_time_str} minutes"
				fi

			fi


			critical_comp_time_str="$(echo "${diag}" | "${jq_exec}" .critical_comp_time)"

			if [ -n "${critical_comp_time_str}" ] && [ "${critical_comp_time_str}" != "null" ]; then
				if [ "${critical_comp_time_str}" = "0" ]; then
					[ $report_ok -eq 1 ] || report "(no period beyond critical temperature logged)"
				else
					report " - logged duration beyond critical temperature: ${critical_comp_time_str} minutes"
				fi

			fi

			# If percentage_used is non-null, degradation started:
			#p_used="$(printf '%s\n' "${diag}" | grep percentage_used | cut -w -f3)"
			#p_used="$(printf '%s\n' "${diag}" | grep percentage_used | cut -w -f3)"
			p_used="$(echo "${diag}" | "${jq_exec}" .percent_used)"

			#if [ "${p_used}" = "0%" ]; then
			if [ "${p_used}" = "0" ]; then

				[ $report_ok -eq 1 ] || report "${p_used_correct_hint}"

			else

				set_warning "non-zero used percentage reported (${p_used}%), ${p_used_problem_hint}."

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

				set_error "available spare (${avail_spare}%) dropped below the low threshold (${avail_spare_t}, this NVME is close to critical condition."

			else

				if [ $avail_spare -lt 100 ]; then

					set_warning "non-optimal available spare (${avail_spare}%, instead of 100%; low threshold (${avail_spare_t}%) not reached yet."

				else

					[ $report_ok -eq 1 ] || report "(ideal 100% spare level; low threshold: ${avail_spare_t}%)"

				fi

			fi


			critical_warning_str="$(echo "${diag}" | "${jq_exec}" .critical_warning)"

			if [ "${critical_warning_str}" = "0" ]; then

				[ $report_ok -eq 1 ] || report "${crit_w_correct_hint}"

			else

				set_error "${critical_warning_str} ${crit_w_problem_hint}."

			fi


			media_errors_str="$(echo "${diag}" | "${jq_exec}" .media_errors)"

			if [ "${media_errors_str}" = "0" ]; then

				[ $report_ok -eq 1 ] || report "${media_error_correct_hint}"

			else

				set_error  "${media_errors_str} ${media_error_problem_hint}."

			fi


			error_log_str="$(echo "${diag}" | "${jq_exec}" .num_err_log_entries)"

			if [ "${error_log_str}" = "0" ]; then

				[ $report_ok -eq 1 ] || report "${error_log_correct_hint}"

			else

				set_warning "${error_log_str} ${error_log_problem_hint}."

			fi


			critical_end_grp_str="$(echo "${diag}" | "${jq_exec}" .endurance_grp_critical_warning_summary)"

			if [ "${critical_end_grp_str}" = "0" ]; then

				[ $report_ok -eq 1 ] || report "${crit_end_grp_correct_hint}"

			else

				set_error "${crit_end_grp_problem_hint} (code ${crit_end_grp_str} reported)."

			fi

			# "Temperature Sensor *" are too detailed.

			# Generally verbose, hard to parse and not that useful:
			#[ $detail -eq 1 ] || "${nvme_exec}" error-log "/dev/$d"

			# Only useful to interpret smart-log:
			#[ $detail -eq 1 ] || "${nvme_exec}" id-ctrl "/dev/$d"

		done

	else

		# Here 'nvme' is not available:

		nvme_prefix=".nvme_smart_health_information_log"

		for d in ${ssd_nvmes}; do

			report "=== For NVME SSD drive $d (fallback):"

			diag="$(run_smartctl $d -j)"

			[ $detail -eq 1 ] || report "NVME SSD fallback diagnosis: ${diag}"

			temp_str="$(echo "${diag}" | "${jq_exec}" .temperature.current)"
			report " - current temperature: ${temp_str}°C"

			power_on_time_str="$(echo "${diag}" | "${jq_exec}" .power_on_time.hours)"

			hours_to_str "${power_on_time_str}"

			power_cycles="$(echo "${diag}" | "${jq_exec}" .power_cycle_count)"
			unsafe_shutdowns="$(echo "${diag}" | "${jq_exec}" ${nvme_prefix}.unsafe_shutdowns)"

			report " - usage duration: ${res}, with ${unsafe_shutdowns} unsafe shutdowns"

			warning_temp_time_str="$(echo "${diag}" | "${jq_exec}" ${nvme_prefix}.warning_temp_time)"

			if [ -n "${warning_temp_time_str}" ]; then

				report " - duration beyond warning temperature: ${warning_temp_time_str} minutes"

			fi


			critical_comp_time_str="$(echo "${diag}" | "${jq_exec}" ${nvme_prefix}.critical_comp_time)"

			if [ -n "${critical_comp_time_str}" ]; then

				report " - duration beyond critical temperature: ${critical_comp_time_str} minutes"

			fi

			if [ -n "${critical_temp_time_str}" ]; then

				report " - duration beyond critical temperature: ${critical_temp_time_str} minutes"

			fi


			p_used="$(echo "${diag}" | "${jq_exec}" ${nvme_prefix}.percentage_used)"

			if [ "${p_used}" = "0" ]; then

				[ $report_ok -eq 1 ] || report "${p_used_correct_hint}"

			else

				set_warning "non-zero used percentage reported (${p_used}%), ${p_used_problem_hint}."

			fi


			end_used="$(echo "${diag}" | "${jq_exec}" .endurance_used.current_percent)"

			if [ "${end_used}" = "0" ]; then

				[ $report_ok -eq 1 ] || report "${end_used_correct_hint}"

			else

				set_warning "non-zero used endurance reported (${end_used}%), ${end_used_problem_hint}."

			fi



			avail_spare_str="$(echo "${diag}" | "${jq_exec}" ${nvme_prefix}.available_spare)"
			avail_spare_t_str="$(echo "${diag}" | "${jq_exec}" ${nvme_prefix}.available_spare_threshold)"

			#echo "available_spare = ${avail_spare_str}, available_spare_threshold=${avail_spare_t_str}"

			avail_spare=$((${avail_spare_str}))
			avail_spare_t=$((${avail_spare_t_str}))

			if [ $avail_spare -lt $avail_spare_t ]; then

				set_error "available spare (${avail_spare}%) dropped below the low threshold (${avail_spare_t}, this NVME is close to critical condition."

			else

				if [ $avail_spare -lt 100 ]; then

					set_warning "non-optimal available spare (${avail_spare}%, instead of 100%; low threshold (${avail_spare_t}%) not reached yet."

				else

					[ $report_ok -eq 1 ] || report "(ideal 100% spare level; low threshold: ${avail_spare_t}%)"

				fi

			fi


			critical_warning_str="$(echo "${diag}" | "${jq_exec}" ${nvme_prefix}.critical_warning)"

			if [ "${critical_warning_str}" = "0" ]; then

				[ $report_ok -eq 1 ] || report "${crit_w_correct_hint}"

			else

				set_error "${critical_warning_str} ${crit_w_problem_hint}."

			fi


			media_error_str="$(echo "${diag}" | "${jq_exec}" ${nvme_prefix}.media_errors)"

			if [ "${media_error_str}" = "0" ]; then

				[ $report_ok -eq 1 ] || report "${media_error_correct_hint}"

			else

				set_error  "${media_error_str} ${media_error_problem_hint}."

			fi


			error_log_str="$(echo "${diag}" | "${jq_exec}" ${nvme_prefix}.num_err_log_entries)"

			if [ "${error_log_str}" = "0" ]; then

				[ $report_ok -eq 1 ] || report "${error_log_correct_hint}"

			else

				set_error "${error_log_str} ${error_log_problem_hint}."

			fi

		done

	fi

fi


# As, with cron, a notication is sent iff a non-zero exit code is returned, or
# if outputs to normal or error file descriptors are made:
#
# (so: report only errors, not warnings or normal messages; and log all messages
# in all cases)
#
if [ $cron -eq 0 ]; then

	if [ $exit_code -eq ${error_code} ]; then

		echo "In cron mode and having reached error level ${error_code}, reporting the diagnoses made:" 1>&2
		cat "${log_file}" 1>&2

		exit ${error_code}

	fi

	# Never reporting warning_code, as this would trigger cron notification:
	exit

else

	# Unadultered:
	exit ${exit_code}

fi
