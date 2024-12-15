#!/bin/sh

# Default:
camera_id=1

#client_tool_name="cvlc"
#client_tool_name="mplayer"
client_tool_name="mpv"


help_short_opt="-h"
help_long_opt="--help"

full_opt="--full"

guidelines="
Using ${client_tool_name}, so to:
 - take a snapshot: use Shift-S
 - start/stop recording: Shift-R
 - quit: Ctrl-Q
"


usage="Usage: $(basename $0) [${help_short_opt}|${help_long_opt}] [${full_opt}] [CAMERA_ID]: performs an online, direct monitoring, with an average quality and audio, of the networked security camera (CCTV) designated by any CAMERA_ID specified, otherwise by the default camera identifier,'${camera_id}'.

Use the ${full_opt} option to access to the higher-resolution stream with audio.
${guidelines}
Of course the firewall of any gateway should block outbound (RTSP) streams.
"

if [ "$1" = "${help_short_opt}" ] || [ "$1" = "${help_long_opt}" ]; then

	echo "${usage}"

	exit

fi


if [ "$1" = "${full_opt}" ]; then
	echo "(higher-resolution stream with audio requested)"
	full_requested=0
	shift

fi

full_requested=1

if [ "$1" = "${full_opt}" ]; then
	echo "(higher-resolution stream with audio requested)"
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

	camera_subtype="${camera_subtype_normal_quality}"

fi


#echo "  - camera subtype: ${camera_subtype}"

# For former Dahua:
#rstp_url="rtsp://${camera_login}:${camera_password}@${camera_hostname}/cam/realmonitor?channel=${camera_channel}&subtype=${camera_subtype}"

# For TP-Link TAPO-C320WS:
rstp_url="rtsp://${camera_login}:${camera_password}@${camera_hostname}/stream${camera_channel}"

#echo "rstp_url = ${rstp_url}"

#verbose_opt="--verbose 0"

# Only the most precise hostname wanted (FQDN too long):
#camera_short_name="$(echo "${camera_hostname}" | sed 's|\..*$||')"

# Not known of mpv, for which screenshot files will be saved as mpv-shotNNNN.jpg
# in the working directory:
#
# snapshot_prefix_opt="--snapshot-prefix=camera-${camera_short_name}-"

echo "  Monitoring now camera of identifier '${camera_id}', i.e. '${camera_hostname}', described as '${camera_description}'..."

echo "${guidelines}"

#echo "${client_tool}" ${verbose_opt} ${snapshot_prefix_opt} ${rstp_url} # 1>/dev/null 2>&1 &

"${client_tool}" ${verbose_opt} ${snapshot_prefix_opt} ${rstp_url} #1>/dev/null 2>&1 &
