#!/bin/sh


usage="  Usage: $(basename $0) PUBLIC_ROOT WORK_ROOT updates base work repository from all public Ceylan-* repositories, using for that the currently selected branches of specified clones. One should ensure beforehand that all source and target repositories are fully up to date (ex: committed and pushed)."


if [ ! $# -eq 2 ] ; then

	echo "$usage" 1>&2
	exit 10

fi


current_dir=$(pwd)


public_root="$1"

if [ ! -d "$public_root" ] ; then

	echo "  Error, public root ($public_root) is not an existing directory.
$usage" 1>&2
	exit 25

fi


public_test_dir="$public_root/Ceylan-Myriad"

if [  ! -d "$public_test_dir" ] ; then

	echo "  Error, public root ($public_root) does not seem to be a suitable public root ($public_test_dir not found).
$usage" 1>&2
	exit 30

fi


# To convert any relative directory into an absolute one:
cd "$public_root"
public_root=$(pwd)
cd $current_dir



work_root="$2"

if [ ! -d "$work_root" ] ; then

	echo "  Error, work root ($work_root) is not an existing directory.
$usage" 1>&2
	exit 15

fi


work_test_dir="$work_root/mock-simulators"

if [  ! -d "$work_test_dir" ] ; then

	echo "  Error, work root ($work_root) does not seem to be a suitable work root ($work_test_dir not found).
$usage" 1>&2
	exit 20

fi


# To convert any relative directory into an absolute one:
cd "$work_root"
work_root=$(pwd)
cd $current_dir


rsync=$(which rsync)

if [ ! -x "$rsync" ] ; then

	echo "  Error, no rsync found." 1>&2
	exit 35

fi


# Not relying on timestamps (no --update):
rsync_opt="--recursive --links"

git_opt="-c color.status=always"

echo
echo " + cleaning public repositories"

cd ${public_root}/Ceylan-Myriad
make -s clean 1>/dev/null

cd ${public_root}/Ceylan-WOOPER
make -s clean 1>/dev/null

cd ${public_root}/Ceylan-Traces
make -s clean 1>/dev/null


cd $work_root


echo " + real-cleaning work directory"
make -s real-clean 1>/dev/null


echo " + checking GIT status of Ceylan-Myriad"
cd ${public_root}/Ceylan-Myriad
git ${git_opt} status

echo " + checking GIT status of Ceylan-WOOPER"
cd ${public_root}/Ceylan-WOOPER
git ${git_opt} status

echo " + checking GIT status of Ceylan-Traces"
cd ${public_root}/Ceylan-Traces
git ${git_opt} status


echo " + updating myriad from Ceylan-Myriad"
cd ${public_root}/Ceylan-Myriad

${rsync} ${rsync_opt} . ${work_root}/myriad


echo " + updating wooper from Ceylan-WOOPER"
cd ${public_root}/Ceylan-WOOPER

${rsync} ${rsync_opt} . ${work_root}/wooper


echo " + updating traces from Ceylan-Traces"
cd ${public_root}/Ceylan-Traces

${rsync} ${rsync_opt} . ${work_root}/traces


echo " + performing final cleanings"
cd ${work_root}
#/bin/rm -f */.gitignore */README.md 2>/dev/null
/bin/rm -rf */.git 2>/dev/null


echo " + status of work repository:"
cd ${work_root}
git ${git_opt} status


echo
echo "Work repository has been updated from public ones."

echo
echo "One may then use: 'git add -u && git commit -m \"Synchronisation update from public sub-layer repositories.\" && git push' ) ; done"
