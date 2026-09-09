#!/bin/sh

# Copyright (C) 2019-2026 Olivier Boudeville
#
# Author: Olivier Boudeville [olivier (dot) boudeville (at) esperide (dot) com]
#
# This file is part of the Ceylan-Hull toolbox (see http://hull.esperide.org).


# Default:
camera_id=1

#client_tool_name="cvlc"
#client_tool_name="mplayer"
client_tool_name="mpv"

# *.ts is for "MPEG Transport Stream":
recording_filepath="$(pwd)/$(date '+%Y%m%d-%Hh%Mm%Ss')-cctv-recording.ts"

help_short_opt="-h"
help_long_opt="--help"

full_short_opt="-f"
full_long_opt="--full"

# At least now for mpv:
guidelines="
Using ${client_tool_name}, whose main keyboard shortcuts are:
 - take a snapshot: s
 - start/stop recording: r (in ${recording_filepath})
 - enter/leave fullscreen mode: f
 - quit: q
"


usage="Usage: $(basename $0) [${help_short_opt}|${help_long_opt}] [${full_short_opt}|${full_long_opt}] [CAMERA_ID]: performs an online, direct monitoring, with an average quality and audio, of the networked security camera (CCTV) designated by any CAMERA_ID specified, otherwise by the default camera identifier,'${camera_id}'.

Use the ${full_short_opt} / ${full_long_opt} option to access to the higher-resolution stream with audio, for cameras that support that.
${guidelines}
Of course the firewall of any gateway should block outbound (RTSP) streams.
"

if [ "$1" = "${help_short_opt}" ] || [ "$1" = "${help_long_opt}" ]; then

	echo "${usage}"

	exit

fi


full_requested=1

if [ "$1" = "${full_short_opt}" ] || [ "$1" = "${full_long_opt}" ]; then
	echo "(higher-resolution stream with audio requested)"
	echo "#### Warning: with the TP-Link TAPO-C320WS, this option may likely result in a stream failure." 1>&2
	full_requested=0
	shift

fi

if [ -n "$1" ]; then
	camera_id="$1"
	echo "Will monitor the camera of identifier '${camera_id}'."
	shift
fi


if [ ! $# -eq 0 ]; then

	printf "  Error, invalid parameters specified.\n${usage}" 1>&2
	exit 5

fi



client_tool="$(which ${client_tool_name} 2>/dev/null)"

if [ ! -x "${client_tool}" ]; then

	echo "  Error, no stream client tool found (no ${client_tool_name})." 1>&2
	exit 10

fi


env_file="${HOME}/.ceylan-settings.etf"

if [ ! -f "${env_file}" ]; then

	echo "  Error, no environment file (${env_file}) found." 1>&2
	exit 5

fi



# Used to rely on a shell-compliant syntax, now Erlang one:
#source "${env_file}"

host_key="camera_${camera_id}_hostname"

camera_hostname=$(/bin/cat ${env_file} | grep -v '^[[:space:]]*%' | grep "${host_key}" | sed 's|.*, "||1' | sed 's|" }.$||1')

if [ -z "${camera_hostname}" ]; then

	echo "  Error, no usable '${host_key}' key entry found in environment file (${env_file})." 1>&2
	exit 20

fi

# Beware that it resolves to the right IP (e.g. not the one of the gateway):
#echo "  - camera hostname: ${camera_hostname}"

desc_key="camera_${camera_id}_description"

camera_description=$(/bin/cat ${env_file} | grep -v '^[[:space:]]*%' | grep "${desc_key}" | sed 's|.*, "||1' | sed 's|" }.$||1')

if [ -z "${camera_description}" ]; then

	echo "  Error, no usable '${desc_key}' key entry found in environment file (${env_file})." 1>&2
	exit 25

fi

#echo "  - camera description: ${camera_description}"


login_key="camera_${camera_id}_login"

camera_login=$(/bin/cat ${env_file} | grep -v '^[[:space:]]*%' | grep "${login_key}" | sed 's|.*, "||1' | sed 's|" }.$||1')

if [ -z "${camera_login}" ]; then

	echo "  Error, no usable '${login_key}' key entry found in environment file (${env_file})." 1>&2
	exit 30

fi

#echo "  - camera login: ${camera_login}"


pass_key="camera_${camera_id}_password"

camera_password="$(/bin/cat ${env_file} | grep -v '^[[:space:]]*%' | grep "${pass_key}" | sed 's|.*, "||1' | sed 's|" }.$||1')"

if [ -z "${camera_password}" ]; then

	echo "  Error, no usable '${pass_key}' key entry found in environment file (${env_file})." 1>&2
	exit 35

fi

#echo "  - camera password: ${camera_password}"


channel_key="camera_${camera_id}_channel"

camera_channel="$(/bin/cat ${env_file} | grep -v '^[[:space:]]*%' | grep "${channel_key}" | sed 's|.*, ||1' | sed 's| }.$||1')"

if [ -z "${camera_channel}" ]; then

	echo "  Error, no usable '${channel_key}' key entry found in environment file (${env_file})." 1>&2
	exit 40

fi

#echo "  - camera channel: ${camera_channel}"



if [ $full_requested -eq 0 ]; then

	#echo "Full quality mode requested."

	# Note that, at least on our settings, this does not work (anymore?) with
	# the TP-Link TAPO-C320WS ("Failed reading RTSP data: End of file"):
	#
	subtype_key="camera_${camera_id}_subtype_high_quality"

	camera_subtype_high_quality="$(/bin/cat ${env_file} | grep -v '^[[:space:]]*%' | grep "${subtype_key}" | sed 's|.*, ||1' | sed 's| }.$||1')"

	if [ -z "${camera_subtype_high_quality}" ]; then

		echo "  Error, no usable '${subtype_key}' key entry found in environment file (${env_file})." 1>&2
		exit 45

	fi

	#echo "  - camera subtype_high_quality: ${camera_subtype_high_quality}"

	camera_subtype="${camera_subtype_high_quality}"

else

	#echo "Normal quality mode requested."

	subtype_key="camera_${camera_id}_subtype_normal_quality"

	camera_subtype_normal_quality="$(/bin/cat ${env_file} | grep -v '^[[:space:]]*%' | grep "${subtype_key}" | sed 's|.*, ||1' | sed 's| }.$||1')"

	if [ -z "${camera_subtype_normal_quality}" ]; then

		echo "  Error, no usable '${subtype_key}' key entry found in environment file (${env_file})." 1>&2
		exit 50

	fi

	#echo "  - camera subtype_normal_quality: ${camera_subtype_normal_quality}"

	client_opts="${client_opts} --no-audio"

	camera_subtype="${camera_subtype_normal_quality}"


fi


#echo "  - camera subtype: ${camera_subtype}"

# For former Dahua:
#rstp_url="rtsp://${camera_login}:${camera_password}@${camera_hostname}/cam/realmonitor?channel=${camera_channel}&subtype=${camera_subtype}"


# For TP-Link TAPO-C320WS:

# Even if it works without specifying it:
camera_port=554

rstp_url="rtsp://${camera_login}:${camera_password}@${camera_hostname}:${camera_port}/stream${camera_subtype}"


#echo "rstp_url = ${rstp_url}"

# Could be added: "--fs", for full-screen
client_opts="${client_opts} --no-cache --rtsp-transport=tcp --profile=low-latency --stream-record=${recording_filepath}"

#verbose_opt="--verbose 0"

# Only the most precise hostname wanted (FQDN too long):
#camera_short_name="$(echo "${camera_hostname}" | sed 's|\..*$||')"

# Not known of mpv, for which screenshot files will be saved as mpv-shotNNNN.jpg
# in the working directory:
#
# snapshot_prefix_opt="--snapshot-prefix=camera-${camera_short_name}-"

echo "  Monitoring now camera of identifier '${camera_id}', i.e. '${camera_hostname}', described as '${camera_description}'..."

echo "${guidelines}"

#echo "${client_tool}" ${client_opts} ${verbose_opt} ${snapshot_prefix_opt} ${rstp_url} # 1>/dev/null 2>&1 &

"${client_tool}" ${client_opts} ${verbose_opt} ${snapshot_prefix_opt} ${rstp_url} 1>/dev/null 2>&1 &
