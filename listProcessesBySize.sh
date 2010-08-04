#!/bin/sh

# Sizes are expressed in Kilobytes.

# Ex:
# > listProcessesBySize.sh
#
#   VSZ CMD
# 196972 konsole
# 165548 /usr/lib/firefox-3.0.19/firefox
# 109668 gaim
# ...


ps -e -o vsize,cmd | grep VSZ | grep -v grep
ps -e -o vsize,cmd | grep -v VSZ | sort -nr | head -n 30
