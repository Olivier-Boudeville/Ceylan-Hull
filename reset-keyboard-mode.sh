#!/bin/sh

#echo "Resetting keyboard mode..."

# Useful whenever for example VMWare (vmplayer) messes with your keyboard (ex:
# w.r.t. control key).

# See also: xmodmap and the System-Preferences-Keyboard-Layouts tab.

setxkbmap


# Useful when the Erlang VM crashed and your terminal (console) does not recover
# well (ex: no more echoing of the typed characters):
#
# (obtained thanks to a diff of 'stty --all' before and after the issue)

# Complete state:
#/bin/stty -ignbrk -brkint -ignpar -parmrk -inpck -istrip -inlcr -igncr icrnl ixon -ixoff -iuclc -ixany -imaxbel iutf8 opost -olcuc -ocrnl onlcr -onocr -onlret -ofill -ofdel nl0 cr0 tab0 bs0 vt0 ff0 isig icanon iexten echo echoe echok -echonl -noflsh -xcase -tostop -echoprt

# Minimal state change:
/bin/stty -brkint -ignpar icrnl -imaxbel opost icanon echo


# That's it!

#echo "...reset!"
