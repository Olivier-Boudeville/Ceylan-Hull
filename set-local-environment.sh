#!/bin/sh

usage="$(basename $0): sets the local UNIX, Esperide environment."

home=${HOME}

cd ${home}

ln -sf ${home}/Projects/Personnel/TO-DO.rst
ln -sf ${home}/Projects/Personnel/TO-BUY.rst
ln -sf ${home}/Projects/Personnel/TO-SCHEDULE.rst


cd ${home}/.emacs.d/
emacs_conf="${CEYLAN_MYRIAD}/conf/init.el"
ln -sf "${emacs_conf}" .
echo "  You may tweak your ${emacs_conf} configuration file."

cd ${home}
