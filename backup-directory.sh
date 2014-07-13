#!/bin/sh

USAGE="Usage: "$(basename $0)" <DIR TO BACKUP> <TARGET SERVER> <TARGET SSH PORT> <TARGET_DIR>: backups specified directory to specified backup directory on specified server, using specified SSH port."

if [ ! $# -eq 4 ] ; then

	echo "  Error, four parameters needed. $USAGE" 1>&2
	exit 5

fi


RSYNC=$(which rsync 2>/dev/null)

if [ ! -x "$RSYNC" ] ; then

	echo "  Error, no rsync available." 1>&2
	exit 10

fi

SCP=$(which scp 2>/dev/null)

if [ ! -x "$SCP" ] ; then

	echo "  Error, no scp available." 1>&2
	exit 15

fi


SOURCE="$1"

if [ ! -e "$SOURCE" ] ; then

	echo "  Error, directory to backup ($SOURCE) does not exist." 1>&2
	exit 20

fi


TARGET_SERVER="$2"

SSH_PORT="$3"

TARGET_BACKUP_DIR="$4"

TARGET="${TARGET_SERVER}:${TARGET_BACKUP_DIR}"



# Testing first if the permissions are ok (otherwise we could run a rsync that
# would fail to transfer anything after hours of copy):
#
DUMMY_TRANSFER="$SOURCE/.bashrc"

# If was not already existing:
touch $DUMMY_TRANSFER

if ! $SCP -P $SSH_PORT $DUMMY_TRANSFER $TARGET 1>/dev/null ; then

	echo "  Errot, test scp failed, no backup attempted." 1>&2
	exit 15

fi


# Not in the transfered directory on purpose:
LOG_FILE="/tmp/$(date '+%Y%m%d')-backup-full-home-directory.log"


# Beware to symlinks, they may lead to backup of infinite size:
#
$RSYNC -r --safe-links --links --rsh="ssh -p $SSH_PORT" /home/$USER/ $TARGET_SERVER:$TARGET_BACKUP_DIR/$(date '+%Y%m%d')-full-$USER-home-from-$(hostname -s) 2>&1 | tee $LOG_FILE

if [ $? -eq 0 ] ; then

	echo "  Backup succeeded."

else

	echo "  Backup failed." 1>&2
	exit 50

fi

echo "Log written in '$LOGFILE'."
