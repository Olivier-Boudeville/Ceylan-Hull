#!/bin/sh

# Sizes are expressed in kilobytes.

# Ex:
# $ listProcessesBySize.sh
#
#   VSZ CMD
# 196972 konsole
# 165548 /usr/lib/firefox-3.0.19/firefox
# 109668 gaim
# ...

# See also: atop -m

echo -e "\tListing running processes by decreasing size in RAM (total VM size in KiB): "
#echo "(see also: atop -m)"

ps -e -o vsize,cmd | grep VSZ | grep -v grep
ps -e -o vsize,cmd | grep -v VSZ | sort -nr | head -n 30
