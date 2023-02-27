#!/bin/sh

# Prefer the brave-bin variant, as compiling from sources is awfully long:
# yay -S brave

echo "  Launching Brave browser"
/usr/bin/brave $* 1>/dev/null 2>&1 &
