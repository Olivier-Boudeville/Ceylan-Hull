#!/bin/sh

usage="Usage: $(basename $0) <DIR TO BACKUP> <TARGET SERVER> <TARGET SSH PORT> <TARGET_DIR>: backups specified directory to specified backup directory on the specified server, using specified SSH port."

if [ ! $# -eq 4 ]; then

	echo "  Error, four parameters needed.
${usage}" 1>&2
	exit 5

fi


rsync=$(which rsync 2>/dev/null)

if [ ! -x "${rsync}" ]; then

	echo "  Error, no rsync available." 1>&2
	exit 10

fi

scp=$(which scp 2>/dev/null)

if [ ! -x "${scp}" ]; then

	echo "  Error, no scp available." 1>&2
	exit 15

fi


source_dir="$1"

if [ ! -d "${source_dir}" ]; then

	echo "  Error, directory to backup (${source_dir}) does not exist." 1>&2
	exit 20

fi


target_server="$2"

ssh_port="$3"

target_backup_dir="$4"

target="${target_server}:${target_backup_dir}"


# Testing first if the permissions are ok (otherwise we could run a rsync that
# would fail to transfer anything after hours of copy):
#
dummy_transfer="${HOME}/.$(basename $0).tmp"

# If was not already existing:
touch ${dummy_transfer}

if ! ${scp} -P ${ssh_port} ${dummy_transfer} ${target} 1>/dev/null; then

	echo "  Errot, test scp failed, no backup attempted." 1>&2
	exit 15

fi

source_name="$(basename ${source_dir})"

# Not in the transferred directory on purpose:
log_file="/tmp/$(date '+%Y%m%d')-backup-full-${source_name}-directory.log"


# Beware to symlinks, they may lead to backups of infinite size:
${rsync} -r --safe-links --links --rsh="ssh -p ${ssh_port}" ${source_dir} ${target_server}:${target_backup_dir}/$(date '+%Y%m%d')-full-${source_name}-from-$(hostname -s) 2>&1 | tee ${log_file}

if [ $? -eq 0 ]; then

	echo "  Backup succeeded."

else

	echo "  Backup failed." 1>&2
	exit 50

fi

echo "Log written in '$LOGFILE'."
