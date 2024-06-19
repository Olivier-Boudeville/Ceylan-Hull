#!/bin/sh

usage="Usage: $(basename $0) [-h|--help] [pre|post]: applies relevant settings for the local host.
This script should be run typically after booting and resuming from suspend, as root.

Two argument may be specified, typically if using systemd-suspend.service (refer to 'man systemd-suspend.service'):
 - 'pre': then nothing special is done
 - 'post': then these fan settings are re-applied (otherwise the system would just return to its defaults)
"


if [ "$1" = "-h" ] || [ "$1" = "--help" ]; then

	echo "${usage}"
	exit

fi


# Otherwise no overwriting (e.g. of pwm1_enable) may be allowed:
set +o noclobber

log_file="${HOME}/.last-fan-control"

echo "Running at $(date) '$0 $*'" > "${log_file}"


# Contains symbolic links pointing in /sys/devices:
#base_device_dir="/sys/class/hwmon"
base_device_dir="/sys/devices"


# To display current fan modes:

# $ for f in /sys/devices/platform/*/hwmon/hwmon*/pwm*_enable; do echo $f; cat
# $f; done

# This may return:
#/sys/devices/platform/nct6775.2560/hwmon/hwmon3/pwm1_enable
#5
#/sys/devices/platform/nct6775.2560/hwmon/hwmon3/pwm2_enable
#5
#/sys/devices/platform/nct6775.2560/hwmon/hwmon3/pwm3_enable
#5
#/sys/devices/platform/nct6775.2560/hwmon/hwmon3/pwm4_enable
#0
#/sys/devices/platform/nct6775.2560/hwmon/hwmon3/pwm5_enable
#0



# To run a script at startup, a relevant approach is to rely on systemd.
#
# For example /etc/systemd/system/fan-control.service may be set to:

# [Unit]
# Description=Apply relevant, host-specified fan settings at startup
#
# [Service]
# Type=simple
# RemainAfterExit=yes
# ExecStart=/usr/local/hull/apply-fan-settings.sh
# TimeoutStartSec=0
#
# [Install]
# WantedBy=default.target


# Then, to register that unit file:
# $ systemctl daemon-reload

# To start it once:
# $ systemctl start fan-control.service

# To check whether this went well:
# $ systemctl status fan-control.service

# To explore more in-depth:
# $ journalctl -u fan-control.service

# To check the corresponding script logs:
# $ cat /root/.last-fan-control

# And to request that, from now on, it is always launched:
# $ systemctl enable fan-control.service


# To also run this script after suspend (when resuming from it), just add a
# symlink to it in the /usr/lib/systemd/system-sleep/ directory.

# Use 'systemctl status systemd-suspend.service' or 'journalctl -u
# systemd-suspend.service' to investigate.


# One may also want to give to specific tools, not running as root, permissions
# to apply settings to fans.
#
# For that, a dedicated UNIX group may be created once for all (as root):
# $ groupadd fanctrl
# $ usermod -a -G fanctrl root
# $ usermod -a -G fanctrl my_user
#
# (any shell of this user shall be respawned to register that new group
# information)


if [ $# -ge 3 ]; then

	echo "  Error, extra parameters specified (full parameters: '$*').
${usage}" | tee --append "${log_file}" 1>&2
	exit 20

fi


# Either no argument or "pre" | "post" plus the next action:
if [ -n "$1" ]; then

	next_action="action"

	# E.g. "suspend", "hibernate", or "suspend-after-failed-hibernate":
	if [ -n "$2" ]; then

		next_action="$2"

	fi

	if [ "$1" = "pre" ]; then

		echo "(pre-${next_action}, nothing done for fan settings)" | tee --append "${log_file}"

		exit 0

	elif [ "$1" = "post" ]; then

		echo "Applying fan setting for post-${next_action}..." | tee --append "${log_file}"

	else

		echo "  Error, invalid parameter specified ('$1')." | tee --append "${log_file}" 1>&2
		exit 25

	fi

else

	echo "(no argument specified)" | tee --append "${log_file}"

fi


# Here, either no argument (boot) or 'post' (resume after suspend), i.e. the two
# target cases:

sensors_cmd="$(which sensors 2>/dev/null)"

if [ ! -x "${sensors_cmd}" ]; then

	echo "  Error, no 'sensors' tool available." | tee --append "${log_file}" 1>&2
	exit 10

fi


if [ ! $(id -u) = 0 ]; then

	echo "  Error, you must be root to do that." | tee --append "${log_file}" 1>&2
	exit 15

fi



hostname="$(hostname -s 2>/dev/null)"

get_temp_script="$(which get-temperatures.sh 2>/dev/null)"

if [ -x "${get_temp_script}" ]; then

	"${get_temp_script}" | tee --append "${log_file}"

fi


echo "Initial fan speeds:" | tee --append "${log_file}"
"${sensors_cmd}" | grep fan | tee --append "${log_file}"


if [ "${hostname}" = "mini" ]; then

	echo "  Applying fan settings for ${hostname}" | tee --append "${log_file}"

	motherboard_dir="${base_device_dir}/platform/nct6775.2592/hwmon/hwmon3"

	# S1 (front top) driven by CPUFAN:
	s1_id=2

	# SYSFAN1 now not connected:
	none_id=3

	# S2 (front bottom) and S3 (back) are coupled and driven by SYSFAN2:
	s2_and_s3_id=4


	# Actually only 2 3 4 exist:
	#pwm_ids="1 2 3 4 5"
	pwm_ids="${s1_id} ${none_id} ${s2_and_s3_id}"

	echo "Initial fan controls:"
	for p in ${pwm_ids}; do

		v="$(cat ${motherboard_dir}/pwm${p})"
		echo "  - for fan${p}: $(expr ${v} \* 100 / 255)%" | tee --append "${log_file}"

	done

	smart_fan_iv_mode=5

	# Most IDs (2 and 3) can be automatically managed:
	smart_ids="${s1_id} ${none_id}"

	echo " - setting PWM fans ${smart_ids} to 'Smart Fan IV' (automatic) mode" | tee --append "${log_file}"

	for p in ${smart_ids}; do

		# e.g. /sys/devices/platform/nct6775.2560/hwmon/hwmon3/pwm1_enable:
		echo ${smart_fan_iv_mode} > ${motherboard_dir}/pwm${p}_enable

	done

	manual_mode=1

	manual_ids="${s2_and_s3_id}"
	echo " - setting PWM fans ${manual_ids} to manual mode" | tee --append "${log_file}"
	for p in ${manual_ids}; do

		# e.g. /sys/devices/platform/nct6775.2560/hwmon/hwmon3/pwm4_enable:
		echo ${manual_mode} > ${motherboard_dir}/pwm${p}_enable

	done

	# May make some strange noises:
	#s2_and_s3_speed=80

	s2_and_s3_speed=90
	#s2_and_s3_speed=0

	echo " - setting explicitly the speed of S2 and S3 (PWM fan ${s2_and_s3_id}) to $(expr ${s2_and_s3_speed} \* 100 / 255)%" | tee --append "${log_file}"

	echo ${s2_and_s3_speed} > ${motherboard_dir}/pwm${s2_and_s3_id}

elif [ "${hostname}" = "fugu" ]; then

	echo "  Applying fan settings for ${hostname}" | tee --append "${log_file}"

	motherboard_dir="${base_device_dir}/platform/nct6775.2560/hwmon/hwmon3"

	# Actually only 2 3 exist:
	#smart_ids="1 2 3 4 5"
	smart_ids="2 3"

	pwm_ids="${smart_ids}"

	smart_fan_iv_mode=5

	echo " - setting PWM fans ${smart_ids} to 'Smart Fan IV' (automatic) mode" | tee --append "${log_file}"

	for p in ${smart_ids}; do

		echo ${smart_fan_iv_mode} > ${motherboard_dir}/pwm${p}_enable

	done

else

	echo "  Error, the local host, '${hostname}', is not known of this script." | tee --append "${log_file}" 1>&2

	exit 15

fi



fan_control_group="fanctrl"

# Fix permissions if a group for fan control exists:
if getent group "${fan_control_group}" 1>/dev/null 2>&1; then

	echo " - setting permissions of PWM fans ${pwm_ids} as readable and writable by group '${fan_control_group}'" | tee --append "${log_file}"

	# Hopefully never more than 9 fans:
	#for f in ${motherboard_dir}/pwm? ${motherboard_dir}/pwm*_enable; do

	# Better:
	for f in ${pwm_ids}; do

		chgrp "${fan_control_group}" "${motherboard_dir}/pwm${f}"

		chmod g+rw "${motherboard_dir}/pwm${f}"

	done

fi


echo "Final non-automatic fan controls:" | tee --append "${log_file}"
for p in ${manual_ids}; do

	v="$(cat ${motherboard_dir}/pwm${p})"
	echo "  - for fan${p}: $(expr ${v} \* 100 / 255)%" | tee --append "${log_file}"

done

echo "(short waiting)" | tee --append "${log_file}"
sleep 2

echo "New fan speeds:" | tee --append "${log_file}"
"${sensors_cmd}" | grep fan | tee --append "${log_file}"

echo "End of fan control." | tee --append "${log_file}"
