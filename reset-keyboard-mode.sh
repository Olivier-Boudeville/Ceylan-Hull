#!/bin/sh

usage="$(basename $0) [-v]: resets the keyboard mode, typically should it have been modified by a misbehaving program.
The -v option stands for verbose"


verbose=1

if [ "$1" = "-v" ]; then

	verbose=0

fi


if [ $verbose -eq 0 ]; then

	echo "Resetting keyboard mode..."

fi



# Useful whenever for example VMWare (vmplayer) messes with your keyboard (ex:
# w.r.t. control key).

# See also: xmodmap and the System-Preferences-Keyboard-Layouts tab.

setxkbmap


# Useful when the Erlang VM crashed and your terminal (console) does not recover
# well (ex: no more echoing of the typed characters):
#
# (obtained thanks to a diff of 'stty --all' before and after the issue)


# Example of a faulty state (each character having to be typed multiple times);

# $ stty --all
#speed 38400 baud; rows 39; columns 157; line = 0;
#intr = ^C; quit = ^\; erase = ^?; kill = ^U; eof = ^D; eol = <undef>; eol2 = <undef>; swtch = <undef>; start = ^Q; stop = ^S; susp = ^Z; rprnt = ^R;
#werase = ^W; lnext = ^V; discard = ^O; min = 1; time = 0;
#-parenb -parodd -cmspar cs8 -hupcl -cstopb cread -clocal -crtscts
#-ignbrk -brkint -ignpar -parmrk -inpck -istrip -inlcr -igncr icrnl ixon -ixoff -iuclc -ixany -imaxbel iutf8
#opost -olcuc -ocrnl onlcr -onocr -onlret -ofill -ofdel nl0 cr0 tab0 bs0 vt0 ff0
#isig icanon iexten echo echoe echok -echonl -noflsh -xcase -tostop -echoprt echoctl echoke -flusho -extproc


# Example of a sane state:

# $ stty --all
#speed 38400 baud; rows 41; columns 172; line = 0;
#intr = ^C; quit = ^\; erase = ^?; kill = ^U; eof = ^D; eol = <undef>; eol2 = <undef>; swtch = <undef>; start = ^Q; stop = ^S; susp = ^Z; rprnt = ^R; werase = ^W; lnext = ^V;
#discard = ^O; min = 1; time = 0;
#-parenb -parodd -cmspar cs8 -hupcl -cstopb cread -clocal -crtscts
#-ignbrk -brkint -ignpar -parmrk -inpck -istrip -inlcr -igncr icrnl ixon -ixoff -iuclc -ixany -imaxbel iutf8
#opost -olcuc -ocrnl onlcr -onocr -onlret -ofill -ofdel nl0 cr0 tab0 bs0 vt0 ff0
#isig icanon iexten echo echoe echok -echonl -noflsh -xcase -tostop -echoprt echoctl echoke -flusho -extproc


# Rather complete state, yet no sufficient in all cases:
/bin/stty -ignbrk -brkint -ignpar -parmrk -inpck -istrip -inlcr -igncr icrnl ixon -ixoff -iuclc -ixany -imaxbel iutf8 opost -olcuc -ocrnl onlcr -onocr -onlret -ofill -ofdel nl0 cr0 tab0 bs0 vt0 ff0 isig icanon iexten echo echoe echok -echonl -noflsh -xcase -tostop -echoprt


# Even more complete, yet no sufficient either:
/bin/stty -parenb -parodd -cmspar cs8 -hupcl -cstopb cread -clocal -crtscts -ignbrk -brkint -ignpar -parmrk -inpck -istrip -inlcr -igncr icrnl ixon -ixoff -iuclc -ixany -imaxbel iutf8 opost -olcuc -ocrnl onlcr -onocr -onlret -ofill -ofdel nl0 cr0 tab0 bs0 vt0 ff0 isig icanon iexten echo echoe echok -echonl -noflsh -xcase -tostop -echoprt echoctl echoke -flusho -extproc


# Minimal state change:
#/bin/stty -brkint -ignpar icrnl -imaxbel opost icanon echo


# That's it!

if [ $verbose -eq 0 ]; then

	echo "...reset!"

fi
