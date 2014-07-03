#!/bin/sh


if ps -edf|grep thunderbird | grep -v grep 1>/dev/null 2>&1 ; then

	echo "   Error, your mail client (thunderbird) seems to \
be still running." 1>&2
	exit 5

fi


cd ~

mail_root="./.thunderbird"

if [ ! -d "$mail_root" ] ; then

	echo "   Error, no root directory of mail client found \
($mail_root)" 1>&2
	exit 10

fi

archive_tool=$(which snapshot.sh 2>/dev/null)

if [ ! -x "$archive_tool" ] ; then

	echo "   Error, no executable archive tool found (snapshot.sh)." 1>&2
	exit 15

fi

#$archive_tool $mail_root

if [ ! $? -eq 0 ] ; then

	echo "   Error, archive creation failed." 1>&2
	exit 20

fi

generated_file=$(date "+%Y%m%d")-.thunderbird-snapshot.tar.xz.gpg

if [ ! -f "$generated_file" ] ; then

	echo "   Error, no generated file ($generated_file) found." 1>&2
	exit 25

fi


target_file=$(date "+%Y%m%d")-courriels-thunderbird.tar.xz.gpg

target_dir="$HOME/Archives/Courriels/"

mkdir -p "$target_dir"

mv -f $generated_file "$target_dir/$target_file"

echo
echo "Mails have been successfully archived in $target_dir/$target_file."
