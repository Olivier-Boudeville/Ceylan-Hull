#!/bin/sh

usage="Usage: $(basename $0): kills all processes related to Unity3D (including UnityHub)"

echo "Killing all processes in link with Unity3D:"
ps -edf | grep -i unity | grep -v grep

killall unityhub-bin Unity 2>/dev/null
killall -9 unityhub-bin Unity 2>/dev/null

# To wipe all persistent state (except projects themselves):
# (nothing in ~/.cache)
#
#/bin/rm -rf ~/.config/UnityHub/ ~/.local/share/UnityHub/
#/bin/rm -rf ~/.config/unity3d/ ~/.local/share/unity3d/

echo
echo "Unity3D processes killed; remaining:"
ps -edf | grep -i unity | grep -v grep
