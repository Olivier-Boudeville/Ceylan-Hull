#!/bin/sh

review_dir="$[HOME}/cctv-recordings-to-review"

usage="Usage: $(basename $0) [-q|--quiet]: fetches locally, in '${review_dir}' (and leaves on remote host) the set of CCTV recordings dating back from yesterday and the three days before. Designed to be called typically from the crontab of your usual reviewing user.
Crontab example:
  # Each day at 2:35 AM:
  35 2 * * * /usr/local/hull/fetch-cctv-monitorings.sh --quiet

Option -q / --quiet prevents any normal output to better integrate in scripts or command-line oneliners."

# We need first to gather the necessary settings.

# As crontab does not use an interactive shell:
shell_init="${HOME}/.bashrc"

if [ -f "${shell_init}" ]; then
	. "${shell_init}"
fi


is_quiet=1

if [ "$1" = "-q" ] || [ "$1" = "--quiet" ]; then

	# Ahah: echo "Quiet mode activated."
	is_quiet=0

fi


# Typically defined in ~/.bashrc.contextual:

if [ -z "${CCTV_SERVER}" ]; then

	echo "  Error, environment variable 'CCTV_SERVER' not defined." 1>&2
	exit 5

fi

if [ -z "${CCTV_BASE_PATH}" ]; then

	echo "  Error, environment variable 'CCTV_BASE_PATH' not defined." 1>&2
	exit 6

fi

if [ -z "${CCTV_PREFIX}" ]; then

	echo "  Error, environment variable 'CCTV_PREFIX' not defined." 1>&2
	exit 7

fi

if [ -z "${CCTV_USER}" ]; then

	echo "  Error, environment variable 'CCTV_USER' not defined." 1>&2
	exit 8

fi

scp="$(which scp)"

# SCP option:
if [ -n "${SSH_PORT}" ]; then
	scp_opt="-P ${SSH_PORT}"
fi

mkdir -p "${review_dir}"

cd "${review_dir}"

yesterday="(date -d '-1 day' '+%Y%m%d')"
day_minus_two="$(date -d '-2 day' '+%Y%m%d')"
day_minus_three="$(date -d '-3 day' '+%Y%m%d')"
day_minus_four="$(date -d '-4 day' '+%Y%m%d')"


if [ $is_quiet -eq 1 ]; then

	echo "Fetching as user ${USER} CCTV recordings from ${CCTV_USER}@${CCTV_SERVER}:${CCTV_BASE_PATH} for yesterday (i.e. ${yesterday}) and the three days before (i.e. ${day_minus_two}, ${day_minus_three} and ${day_minus_four}):"

fi


${scp} ${scp_opt} ${CCTV_USER}@${CCTV_SERVER}:${CCTV_BASE_PATH}/${CCTV_PREFIX}*${day_minus_four}*.mkv ${CCTV_USER}@${CCTV_SERVER}:${CCTV_BASE_PATH}/${CCTV_PREFIX}*${day_minus_three}*.mkv ${CCTV_USER}@${CCTV_SERVER}:${CCTV_BASE_PATH}/${CCTV_PREFIX}*${day_minus_two}*.mkv ${CCTV_USER}@${CCTV_SERVER}:${CCTV_BASE_PATH}/${CCTV_PREFIX}*${yesterday}*.mkv . 2>/dev/null

# Disabled, as returns an error as soon as there is no recording for at least
# one of these days (which is however normal):
#
#if [ ! $? -eq 0 ]; then
#
#	echo "  Error, the fetching of CCTV recordings failed (no recording available?)." 1>&2
#
#	exit 15
#
#fi
