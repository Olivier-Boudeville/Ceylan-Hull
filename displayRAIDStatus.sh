#!/bin/bash

RAID_DEVICE="/dev/md0"

cat /proc/mdstat

lsraid -a ${RAID_DEVICE}
mdadm --detail ${RAID_DEVICE}
