#!/bin/bash

usage="$(basename $0): displays information regarding a local RAID array."

raid_device="/dev/md0"

cat /proc/mdstat

# Not available on Debian: lsraid -a ${raid_device}
mdadm --detail ${raid_device}
