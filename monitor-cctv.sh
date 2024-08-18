#!/bin/sh

full_opt="--full"

usage="Usage: $(basename $0) [${full_opt}]: performs online, direct monitoring from a networked security camera (CCTV), with an average quality and audio.
	Use the ${full_opt} option to access to the higher-resolution stream with audio.
	Hit:
	 - Shift-S to take a snapshot
	 - Shift-R to start/stop recording
	 - Ctrl-Q to quit

Of course the firewall of a gateway may block outbound (RTSP) streams.
"

full_requested=1

if [ "$1" = "${full_opt}" ]; then
	echo "(higher-resolution stream with audio requested)"
	full_requested=0
	shift

fi

if [ ! $# -eq 0 ]; then

	printf "  Error, too many parameters specified.\n${usage}" 1>&2
	exit 5

fi


#client_tool_name="cvlc"
#client_tool_name="mplayer"
client_tool_name="mpv"

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

camera_hostname=$(/bin/cat ${env_file} | grep -v '^[[:space:]]*%' | grep camera_1_hostname | sed 's|.*, "||1' | sed 's|" }.$||1')

if [ -z "${camera_hostname}" ]; then

	echo "  Error, no usable camera_hostname key entry found in environment file (${env_file})." 1>&2
	exit 20

fi

#echo "  - camera hostname: ${camera_hostname}"


camera_description=$(/bin/cat ${env_file} | grep -v '^[[:space:]]*%' | grep camera_1_description | sed 's|.*, "||1' | sed 's|" }.$||1')

if [ -z "${camera_description}" ]; then

	echo "  Error, no usable camera_description key entry found in environment file (${env_file})." 1>&2
	exit 20

fi

#echo "  - camera description: ${camera_description}"



camera_login=$(/bin/cat ${env_file} | grep -v '^[[:space:]]*%' | grep camera_1_login | sed 's|.*, "||1' | sed 's|" }.$||1')

if [ -z "${camera_login}" ]; then

	echo "  Error, no usable camera_login key entry found in environment file (${env_file})." 1>&2
	exit 20

fi

#echo "  - camera login: ${camera_login}"


camera_password="$(/bin/cat ${env_file} | grep -v '^[[:space:]]*%' | grep camera_1_password | sed 's|.*, "||1' | sed 's|" }.$||1')"

if [ -z "${camera_password}" ]; then

	echo "  Error, no usable camera_password key entry found in environment file (${env_file})." 1>&2
	exit 20

fi

#echo "  - camera password: ${camera_password}"



camera_channel="$(/bin/cat ${env_file} | grep -v '^[[:space:]]*%' | grep camera_1_channel | sed 's|.*, ||1' | sed 's| }.$||1')"

if [ -z "${camera_channel}" ]; then

	echo "  Error, no usable camera_channel key entry found in environment file (${env_file})." 1>&2
	exit 20

fi

#echo "  - camera channel: ${camera_channel}"



if [ $full_requested -eq 0 ]; then

	#echo "Full quality mode requested."

	camera_subtype_high_quality="$(/bin/cat ${env_file} | grep -v '^[[:space:]]*%' | grep camera_1_subtype_high_quality | sed 's|.*, ||1' | sed 's| }.$||1')"

	if [ -z "${camera_subtype_high_quality}" ]; then

		echo "  Error, no usable camera_subtype_high_quality key entry found in environment file (${env_file})." 1>&2
		exit 20

	fi

	#echo "  - camera subtype_high_quality: ${camera_subtype_high_quality}"

	camera_subtype="${camera_subtype_high_quality}"

else

	#echo "Normal quality mode requested."

	camera_subtype_normal_quality="$(/bin/cat ${env_file} | grep -v '^[[:space:]]*%' | grep camera_1_subtype_normal_quality | sed 's|.*, ||1' | sed 's| }.$||1')"

	if [ -z "${camera_subtype_normal_quality}" ]; then

		echo "  Error, no usable camera_subtype_normal_quality key entry found in environment file (${env_file})." 1>&2
		exit 20

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
camera_short_name="$(echo "${camera_hostname}" | sed 's|\..*$||')"

#snapshot_prefix_opt="--snapshot-prefix=camera-${camera_short_name}-"

echo "  Monitoring now camera '${camera_description}'..."

#echo ${client_tool} ${verbose_opt} ${snapshot_prefix_opt} ${rstp_url} # 1>/dev/null 2>&1 &

${client_tool} ${verbose_opt} ${snapshot_prefix_opt} ${rstp_url} 1>/dev/null 2>&1 &
