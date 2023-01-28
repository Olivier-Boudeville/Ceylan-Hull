#!/bin/sh

usage="Usage: $(basename $0): archives properly and reliably (compressed, cyphered, possibly transferred) the user emails. Always useful/safer, even for IMAP accounts."

# (typically: evolution or thunderbird local state).

# Notes:
# - applies certainly to POP3 accounts, but also for safety on IMAP ones
# - one should have cleaned up one's email base first (removing useless
# emails and larger attachments, emptying the trash, compacting folders, etc.)
# and shut down one's email client.

if [ ! $# -eq 0 ]; then

	echo "   Error, no parameter is to be specified to this script.
${usage}" 1>&2
	exit 4

fi


# Awful PGP support:
target_client="thunderbird"

# Constant problems with at least some IMAP servers:
#target_client="evolution"


if [ "${target_client}" = "thunderbird" ]; then

	email_root="${HOME}/.thunderbird"

	# For the leading dot:
	snapshot_name="thunderbird"

elif [ "${target_client}" = "evolution" ]; then

	email_root="${HOME}/.local/share/evolution"
	snapshot_name="evolution"

fi


# Evolution processes never stopped (or use '--force-shutdown'):
if [ ! "${target_client}" = "evolution" ]; then

	if ps -edf | grep "${target_client}" | grep -v grep 1>/dev/null 2>&1; then

		echo "   Error, your email client (${target_client}) seems to be still running, please shut it down first." 1>&2
		exit 5

	fi

fi


cd ~


if [ ! -d "${email_root}" ]; then

	echo "   Error, no root directory of email client found (${email_root})." 1>&2
	exit 10

fi

archive_tool="$(which snapshot.sh 2>/dev/null)"

if [ ! -x "${archive_tool}" ]; then

	echo "   Error, no executable archive tool found (snapshot.sh)." 1>&2
	exit 15

fi

echo "   Archiving now the current email base...."
${archive_tool} "${email_root}"

if [ ! $? -eq 0 ]; then

	echo "   Error, archive creation failed." 1>&2
	exit 20

fi


generated_file="$(date "+%Y%m%d")-${snapshot_name}-snapshot.tar.xz.gpg"

if [ ! -f "${generated_file}" ]; then

	echo "   Error, no generated file (${generated_file}) found." 1>&2
	exit 25

fi


target_dir="${HOME}/Archives/Courriels"

mkdir -p "${target_dir}"

target_file="$(date "+%Y%m%d")-courriels-${target_client}.tar.xz.gpg"

target_path="${target_dir}/${target_file}"

/bin/mv -f ${generated_file} "${target_path}"

size="$(du -sh "${target_path}" | cut -f 1)"

echo
echo "Emails have been successfully archived in ${target_dir}/${target_file}, whose size is ${size}."


if [ -n "${TO_EMAIL_ARCHIVE}" ]; then

	/bin/scp $SP "${target_path}" "${TO_EMAIL_ARCHIVE}" && echo "Email archive also transferred to ${TO_EMAIL_ARCHIVE}."

fi
