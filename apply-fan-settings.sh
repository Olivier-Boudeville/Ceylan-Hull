#!/bin/sh

# Contains symbolic links pointing in /sys/devices:
#base_device_dir="/sys/class/hwmon"
base_device_dir="/sys/devices"

usage="Usage: $(basename $0): applies relevant settings for the local host.
This script should be run as root, typically after boot, unless specific permissions have been applied first in ${base_device_dir}."

sensors_cmd=$(which sensors 2>/dev/null)

if [ ! -x "${sensors_cmd}" ]; then

	echo "  Error, no 'sensors' tool available." 1>&2

	exit 10

fi


# Otherwise no overwriting may be allowed:
set +o noclobber

hostname="$(hostname -s 2>/dev/null)"

echo "Initial fan speeds:"
sensors | grep fan


if [ "${hostname}" = "mini" ]; then

	echo "  Applying fan settings for mini"

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

		echo ${smart_fan_iv_mode} > ${motherboard_dir}/pwm${p}_enable

	done

	manual_ids="${s2_and_s3_id}"
	# May make some strange noises:
	#s2_and_s3_speed=80

	s2_and_s3_speed=90
	#s2_and_s3_speed=0

	echo " - setting explicitly the speed of S2 and S3 (PWM fan ${s2_and_s3_id}) to $(expr ${s2_and_s3_speed} \* 100 / 255)%"

	echo ${s2_and_s3_speed} > ${motherboard_dir}/pwm${s2_and_s3_id}

else

	echo "  Error, local host, '${hostname}', is not referenced by this script." 1>&2

	exit 15

fi


echo "Final non-automatic fan controls:"
for p in ${manual_ids}; do

	v="$(cat ${motherboard_dir}/pwm${p})"
	echo "  - for fan${p}: $(expr ${v} \* 100 / 255)%"

done

echo "(short waiting)"
sleep 1

echo "New fan speeds:"
sensors | grep fan
