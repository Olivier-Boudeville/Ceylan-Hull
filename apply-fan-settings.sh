#!/bin/sh


usage="Usage: $(basename $0) [pre|post]: applies relevant settings for the local host.
This script should be run typically after booting and resuming from suspend, as root.

Two argument may be specified, typically if using systemd-suspend.service (refer to 'man systemd-suspend.service'):
 - 'pre': then nothing special is done
 - 'post': then these fan settings are re-applied (otherwise the system would just return to its defaults)
"


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

# And to request that, from now on, it is always launched:
# $ systemctl enable fan-control.service


# To also run this script after suspend (when resuming from it), just add a
# symlink to it in the /usr/lib/systemd/system-sleep/ directory.

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


if [ $# -ge 2 ]; then

	echo "  Error, extra parameters specified.
${usage}" 1>&2
	exit 20

fi


if [ -n "$1" ]; then

	if [ "$1" = "pre" ]; then

		echo "(pre-suspend, nothing done for fan settings)"

		exit 0

	elif [ "$1" != "post" ]; then

		echo "  Error, invalid parameter specified ('$1')." 1>&2
		exit 25

	fi

fi


# Here, either no argument (boot) or 'post' (resume after suspend), i.e. the two
# target cases:

sensors_cmd="$(which sensors 2>/dev/null)"

if [ ! -x "${sensors_cmd}" ]; then

	echo "  Error, no 'sensors' tool available." 1>&2

	exit 10

fi


if [ ! $(id -u) = "0" ]; then

	echo "  Error, you must be root to do that." 1>&2

	exit 15

fi


# Otherwise no overwriting may be allowed:
set +o noclobber

hostname="$(hostname -s 2>/dev/null)"

# Taken from our get-temperatures.sh script:
#echo "Current temperatures:"
#"${sensors_cmd}" | grep '°C' | sed 's|(.*)||g' | sed '/^[[:space:]]*$/d' | sed 's|°C.*$|°C|1' | grep -v '+0.0°C' | grep -vE '\-[0-9]*\.[0-9]*°C' | grep -vE '\+127\..*°C'

get_temp_script="$(which get-temperatures.sh 2>/dev/null)"

if [ -x "${get_temp_script}" ]; then

	"${get_temp_script}"

fi




echo "Initial fan speeds:"
"${sensors_cmd}" | grep fan


if [ "${hostname}" = "mini" ]; then

	echo "  Applying fan settings for ${hostname}"

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
		echo "  - for fan${p}: $(expr ${v} \* 100 / 255)%"

	done

	smart_fan_iv_mode=5

	# Most IDs (2 and 3) can be automatically managed:
	smart_ids="${s1_id} ${none_id}"
	echo " - setting PWM fans ${smart_ids} to 'Smart Fan IV' (automatic) mode"
	for p in ${smart_ids}; do

		# e.g. /sys/devices/platform/nct6775.2560/hwmon/hwmon3/pwm1_enable:
		echo ${smart_fan_iv_mode} > ${motherboard_dir}/pwm${p}_enable

	done

	manual_ids="${s2_and_s3_id}"
	# May make some strange noises:
	#s2_and_s3_speed=80

	s2_and_s3_speed=90
	#s2_and_s3_speed=0

	echo " - setting explicitly the speed of S2 and S3 (PWM fan ${s2_and_s3_id}) to $(expr ${s2_and_s3_speed} \* 100 / 255)%"

	echo ${s2_and_s3_speed} > ${motherboard_dir}/pwm${s2_and_s3_id}


elif [ "${hostname}" = "fugu" ]; then

	echo "  Applying fan settings for ${hostname}"

	motherboard_dir="${base_device_dir}/platform/nct6775.2592/hwmon/hwmon3"

else

	echo "  Error, the local host, '${hostname}', is not known of this script." 1>&2

	exit 15

fi



fan_control_group="fanctrl"

# Fix permissions if a group for fan control exists:
if getent group "${fan_control_group}" 1>/dev/null 2>&1; then

	echo " - setting permissions of PWM fans ${pwm_ids} as readable and writable by group '${fan_control_group}'"

	# Hopefully never more than 9 fans:
	#for f in ${motherboard_dir}/pwm? ${motherboard_dir}/pwm*_enable; do

	# Better:
	for f in ${pwm_ids}; do

		chgr "${fan_control_group}" "${motherboard_dir}/pwm${f}"

		chmod g+rw "${motherboard_dir}/pwm${f}"

	done

fi


echo "Final non-automatic fan controls:"
for p in ${manual_ids}; do

	v="$(cat ${motherboard_dir}/pwm${p})"
	echo "  - for fan${p}: $(expr ${v} \* 100 / 255)%"

done

echo "(short waiting)"
sleep 2

echo "New fan speeds:"
"${sensors_cmd}" | grep fan
