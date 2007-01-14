#!/bin/sh

export SCRIPT_DIR="/etc/init.d"

echo "Entering updateBootSequence"


RC_DIR="/etc/rcS.d"

echo -e "\t+ disabling useless starts in $RC_DIR"

# No NFS, rtc module nowhere to be found (aliased to char-major-10-135)
TO_DISABLE="mountnfs hwclockfirst hwclock" 

cd $RC_DIR

for s in $TO_DISABLE; do

	if [ -x S??$s ]; then
		TARGET=`ls S??$s`
		mv $TARGET disabled-$TARGET
	fi

done



RC_DIR="/etc/rc2.d"
echo -e "\t+ disabling useless starts in $RC_DIR"

TO_DISABLE="ppp exim lpd gdm kdm xdm nfs-common nfs-kernel-server" 

cd $RC_DIR

for s in $TO_DISABLE; do

	if [ -x S??$s ]; then
		TARGET=`ls S??$s`
		mv $TARGET disabled-$TARGET
	fi

done

echo -e "\t+ adding home-made starts in $RC_DIR"

ln -sf $SCRIPT_DIR/setFirewall.sh S15setFirewall.sh


echo "updateBootSequence is finished"
