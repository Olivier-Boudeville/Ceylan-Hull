#!/bin/bash

RAID_DEVICE="/dev/md0"

cat /proc/mdstat

# Not available on Debian: lsraid -a ${RAID_DEVICE}
mdadm --detail ${RAID_DEVICE}
