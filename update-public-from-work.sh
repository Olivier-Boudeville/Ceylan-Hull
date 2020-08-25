#!/bin/sh


usage="  Usage: $(basename $0) WORK_ROOT PUBLIC_ROOT: updates all public Ceylan-* repositories from base work one, using for that the currently selected branches of specified clones. One should ensure beforehand that all source and target repositories are fully up to date (ex: committed and pushed)."


if [ ! $# -eq 2 ]; then

	echo "$usage" 1>&2
	exit 10

fi

current_dir=$(pwd)

work_root="$1"

if [ ! -d "$work_root" ]; then

	echo "  Error, work root ($work_root) is not an existing directory.
$usage" 1>&2
	exit 15

fi


work_test_dir="$work_root/mock-simulators"

if [ ! -d "$work_test_dir" ]; then

	echo "  Error, work root ($work_root) does not seem to be a suitable work root ($work_test_dir not found).
$usage" 1>&2
	exit 20

fi


# To convert any relative directory into an absolute one:
cd "$work_root"
work_root=$(pwd)
cd $current_dir


public_root="$2"

if [ ! -d "$public_root" ]; then

	echo "  Error, public root ($public_root) is not an existing directory.
$usage" 1>&2
	exit 25

fi


public_test_dir="$public_root/myriad"

if [  ! -d "$public_test_dir" ]; then

	echo "  Error, public root ($public_root) does not seem to be a suitable public root ($public_test_dir not found).
$usage" 1>&2
	exit 30

fi

# To convert any relative directory into an absolute one:
cd "$public_root"
public_root=$(pwd)
cd $current_dir


rsync=$(which rsync)

if [ ! -x "$rsync" ]; then

	echo "  Error, no rsync found." 1>&2
	exit 35

fi


# Not relying on timestamps (no --update):
rsync_opt="--recursive --links"

git_opt="-c color.status=always"

cd "$work_root"

echo
echo " + real-cleaning work directory (in $(pwd))"
make -s real-clean 1>/dev/null

echo
echo " + cleaning public repositories (in ${public_root})"

cd ${public_root}/myriad
make -s clean 1>/dev/null

cd ${public_root}/wooper
make -s clean 1>/dev/null

cd ${public_root}/traces
make -s clean 1>/dev/null


cd $work_root


echo " + checking git ${git_opt} status of work directory"
git ${git_opt} status


echo " + updating public myriad from local one"
cd myriad

${rsync} ${rsync_opt} . ${public_root}/myriad

echo " + status of public myriad:"
cd ${public_root}/myriad
git ${git_opt} status
cd ${work_root}


echo " + updating public wooper from local one"
cd wooper

${rsync} ${rsync_opt} . ${public_root}/wooper

echo " + status of public wooper:"
cd ${public_root}/wooper
git ${git_opt} status
cd ${work_root}


echo " + updating public traces from local one"
cd traces

${rsync} ${rsync_opt} . ${public_root}/traces

echo " + status of public traces:"
cd ${public_root}/traces
git ${git_opt} status
cd ${work_root}



echo
echo "Public repositories have been updated from work one."

echo
echo "One may then use: 'cd ${public_root} && for p in myriad wooper traces ; do ( cd \$p ; git add -u && git commit -m \"Synchronisation update.\" && git push ) ; done'"
