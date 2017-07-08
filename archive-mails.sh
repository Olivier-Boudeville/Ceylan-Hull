#!/bin/sh

USAGE="Usage:"$(basename $0)

# Archives properly user mails (typically: thunderbird local state).

# Note: one should have cleaned up one's mail base first (removing useless mails
# and larger attachments, emptying the trash, compacting folders, etc.) and shut
# down one's mail client.

if [ ! $# -eq 0 ] ; then

	echo "   Error, no parameter is to be specified to this script." 1>&2
	exit 4

fi


if ps -edf| grep thunderbird | grep -v grep 1>/dev/null 2>&1 ; then

	echo "   Error, your mail client (thunderbird) seems to \
be still running." 1>&2
	exit 5

fi


cd ~

mail_root="./.thunderbird"

if [ ! -d "$mail_root" ] ; then

	echo "   Error, no root directory of mail client found \
($mail_root)." 1>&2
	exit 10

fi

archive_tool=$(which snapshot.sh 2>/dev/null)

if [ ! -x "$archive_tool" ] ; then

	echo "   Error, no executable archive tool found (snapshot.sh)." 1>&2
	exit 15

fi

echo "   Archiving now the current mail base...."
$archive_tool $mail_root

if [ ! $? -eq 0 ] ; then

	echo "   Error, archive creation failed." 1>&2
	exit 20

fi

generated_file=$(date "+%Y%m%d")-.thunderbird-snapshot.tar.xz.gpg

if [ ! -f "$generated_file" ] ; then

	echo "   Error, no generated file ($generated_file) found." 1>&2
	exit 25

fi


target_dir="$HOME/Archives/Courriels"

mkdir -p "$target_dir"

target_file=$(date "+%Y%m%d")-courriels-thunderbird.tar.xz.gpg

target_path="$target_dir/$target_file"

mv -f $generated_file "$target_path"

size=$(du -sh "$target_path" | cut -f 1)

echo
echo "Mails have been successfully archived in $target_dir/$target_file - \
whose size is $size."

if [ -n "${TO_MAIL_ARCHIVE}" ] ; then

	/bin/scp $SP "$target_path" "${TO_MAIL_ARCHIVE}" && echo "Mail archive also transferred to ${TO_MAIL_ARCHIVE}."

fi
