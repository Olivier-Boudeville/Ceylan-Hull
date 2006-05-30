#!/bin/bash

# This script is made to be executed in a fresh installation of Debian 3.0
# It will copy relevant files.

# Author : Olivier Boudeville (olivier.boudeville@online.fr)
# Created : 2003, June, 21

HOME_DIR="/home/$USER"

waitForKey()
{
	read -s -n1 -p "Press Enter key to continue"  keypress
}

echo -e "\n\tInstalling base files on `hostname`"
cp -f hosts profile resolv.conf BannerForSSH.txt gpm.conf lilo.conf modules /etc
cp -f options /etc/network
cp -f bootmess.txt /boot
cp -f sources.list /etc/apt
cp -f ssh_config /etc/ssh
cp -f vimrc /etc/vim
cp -f xserverrc /usr/X11R6/lib/X11/xinit
cp -f XF86Config-4 /etc/X11
cp -f bootmisc.sh networking ppp ddclient netchooser.sh setGatewayBox.sh setLANBox.sh testNetwork.sh setFirewall.sh iptables.rules-*.sh /etc/init.d
cp -f .bash* .nedit .Xdefaults config-* /root
cp -f .bash* .nedit .cvsrc .Xdefaults -r bin ${HOME_DIR}
cp -f slocate /etc/cron.daily

echo "After apt-get install ddclient"
cp -f ddclient.conf /etc/default
cp -f ddclient-up /etc/ppp/ip-up.d
cp -f ddclient /etc/init.d

echo -e "\nInstallation of base files finished"
