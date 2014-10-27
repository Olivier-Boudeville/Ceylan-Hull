#!/bin/sh


USAGE="  Usage: "$(basename $0)" WORK_ROOT PUBLIC_ROOT: updates all public Ceylan-* repositories from base work one."


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
make -s real-clean 1>/dev/null

echo
echo " + cleaning public repositories"

cd ${PUBLIC_ROOT}/Ceylan-Myriad
make -s clean 1>/dev/null

cd ${PUBLIC_ROOT}/Ceylan-WOOPER
make -s clean 1>/dev/null

cd ${PUBLIC_ROOT}/Ceylan-Traces
make -s clean 1>/dev/null


cd $WORK_ROOT

echo " + checking GIT status of work directory"
git status


echo " + updating Ceylan-Myriad from common"
cd common

${RSYNC} ${RSYNC_OPT} . ${PUBLIC_ROOT}/Ceylan-Myriad


echo " + status of Ceylan-Myriad:"
cd ${PUBLIC_ROOT}/Ceylan-Myriad
git status
cd ${WORK_ROOT}


echo " + updating Ceylan-WOOPER from wooper"
cd wooper

${RSYNC} ${RSYNC_OPT} . ${PUBLIC_ROOT}/Ceylan-WOOPER

echo " + status of Ceylan-WOOPER:"
cd ${PUBLIC_ROOT}/Ceylan-WOOPER
git status
cd ${WORK_ROOT}


echo " + updating Ceylan-Traces from traces"
cd traces

${RSYNC} ${RSYNC_OPT} . ${PUBLIC_ROOT}/Ceylan-Traces
echo " + status of Ceylan-Traces:"
cd ${PUBLIC_ROOT}/Ceylan-Traces
git status
cd ${WORK_ROOT}



echo
echo "Public repositories have been updated from work one."

echo
echo "One may then use: 'for p in Myriad WOOPER Traces ; do ( cd Ceylan-\$p ; git add -u && git commit -m \"Synchronisation update.\" && git push' ) ; done"
