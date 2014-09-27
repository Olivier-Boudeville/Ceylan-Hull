#!/bin/sh


USAGE="  Usage: "$(basename $0)" WORK_ROOT PUBLIC_ROOT: updates all public Ceylan-* repositories from base work one.

  Example: "$(basename $0)" ~/Projects/Sim-Diasca/sources/Sim-Diasca"



if [ ! $# -eq 2 ] ; then

	echo "$USAGE" 1>&2
	exit 10

fi

WORK_ROOT="$1"

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


PUBLIC_ROOT="$2"
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


RSYNC=$(which rsync)

if [ ! -x "$RSYNC" ] ; then

	echo "  Error, no rsync found." 1>&2
	exit 35

fi


# Not relying on timestamps (no --update):
RSYNC_OPT="--recursive "

cd $WORK_ROOT

echo

echo " + real-cleaning work directory"
#make -s real-clean 1>/dev/null

echo " + checking GIT status of work directory"
git status


echo " + updating Ceylan-Myriad from common"
cd common

${RSYNC} ${RSYNC_OPT} . ${PUBLIC_ROOT}/Ceylan-Myriad

cd ..


echo " + updating Ceylan-WOOPER from wooper"
cd wooper

${RSYNC} ${RSYNC_OPT} . ${PUBLIC_ROOT}/Ceylan-WOOPER

cd ..


echo " + updating Ceylan-Traces from traces"
cd traces

${RSYNC} ${RSYNC_OPT} . ${PUBLIC_ROOT}/Ceylan-Traces

cd ..


echo
echo "Public repositories have been updated from work one."

echo "One may then use: 'git add -u && git commit -m \"Synchronisation update.\" && git push'"
