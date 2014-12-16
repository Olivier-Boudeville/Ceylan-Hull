#!/bin/sh


USAGE="  Usage: "$(basename $0)" PUBLIC_ROOT WORK_ROOT: updates base work repository from all public Ceylan-* repositories."


if [ ! $# -eq 2 ] ; then

	echo "$USAGE" 1>&2
	exit 10

fi


current_dir=$(pwd)


PUBLIC_ROOT="$1"

if [ ! -d "$PUBLIC_ROOT" ] ; then

	echo "  Error, public root ($PUBLIC_ROOT) is not an existing directory.
$USAGE" 1>&2
	exit 25

fi


PUBLIC_TEST_DIR="$PUBLIC_ROOT/Ceylan-Myriad"

if [  ! -d "$PUBLIC_TEST_DIR" ] ; then

	echo "  Error, public root ($PUBLIC_ROOT) does not seem to be a suitable public root ($PUBLIC_TEST_DIR not found).
$USAGE" 1>&2
	exit 30

fi


# To convert any relative directory into an absolute one:
cd "$PUBLIC_ROOT"
PUBLIC_ROOT=$(pwd)
cd $current_dir



WORK_ROOT="$2"

if [ ! -d "$WORK_ROOT" ] ; then

	echo "  Error, work root ($WORK_ROOT) is not an existing directory.
$USAGE" 1>&2
	exit 15

fi


WORK_TEST_DIR="$WORK_ROOT/mock-simulators"

if [  ! -d "$WORK_TEST_DIR" ] ; then

	echo "  Error, work root ($WORK_ROOT) does not seem to be a suitable work root ($WORK_TEST_DIR not found).
$USAGE" 1>&2
	exit 20

fi


# To convert any relative directory into an absolute one:
cd "$WORK_ROOT"
WORK_ROOT=$(pwd)
cd $current_dir



RSYNC=$(which rsync)

if [ ! -x "$RSYNC" ] ; then

	echo "  Error, no rsync found." 1>&2
	exit 35

fi


# Not relying on timestamps (no --update):
RSYNC_OPT="--recursive "


echo
echo " + cleaning public repositories"

cd ${PUBLIC_ROOT}/Ceylan-Myriad
make -s clean 1>/dev/null

cd ${PUBLIC_ROOT}/Ceylan-WOOPER
make -s clean 1>/dev/null

cd ${PUBLIC_ROOT}/Ceylan-Traces
make -s clean 1>/dev/null


cd $WORK_ROOT


echo " + real-cleaning work directory"
make -s real-clean 1>/dev/null


echo " + checking GIT status of Ceylan-Myriad"
cd ${PUBLIC_ROOT}/Ceylan-Myriad
git status

echo " + checking GIT status of Ceylan-WOOPER"
cd ${PUBLIC_ROOT}/Ceylan-WOOPER
git status

echo " + checking GIT status of Ceylan-Traces"
cd ${PUBLIC_ROOT}/Ceylan-Traces
git status


echo " + updating common from Ceylan-Myriad"
cd ${PUBLIC_ROOT}/Ceylan-Myriad

${RSYNC} ${RSYNC_OPT} . ${WORK_ROOT}/common


echo " + updating wooper from Ceylan-WOOPER"
cd ${PUBLIC_ROOT}/Ceylan-WOOPER

${RSYNC} ${RSYNC_OPT} . ${WORK_ROOT}/wooper


echo " + updating traces from Ceylan-Traces"
cd ${PUBLIC_ROOT}/Ceylan-Traces

${RSYNC} ${RSYNC_OPT} . ${WORK_ROOT}/traces


echo " + performing final cleanings"
cd ${WORK_ROOT}
/bin/rm -f */.gitignore */README.md 2>/dev/null
/bin/rm -rf */.git 2>/dev/null


echo " + status of work repository:"
cd ${WORK_ROOT}
git status


echo
echo "Work repository has been updated from public ones."

echo
echo "One may then use: 'git add -u && git commit -m \"Synchronisation update from public sub-layer repositories.\" && git push' ) ; done"
