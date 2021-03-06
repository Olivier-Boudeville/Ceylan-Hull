#!/bin/sh

usage="Usage: $(basename $0): displays a screen to a video projector (various examples thereof)."


#xrandr --output VGA --pos 0x0 --mode 1024x768 --rate 75

# Also:

#xrandr --output VGA-0 --pos 0x0 --mode 1024x768 --rate 60
xrandr --output VGA-0 --auto --right-of LVDS

# I tend to prefer clones (replacing '--right-of' by '--same-as'):

# xrandr --output VGA --pos 0x0 --mode 1024x768 --same-as LVDS
# xrandr --output VGA --pos 0x0 --rate 75 --mode 1024x768 --same-as LVDS
# xrandr --output DP-3 --pos 0x0 --mode 1920x1080 --same-as VGA-0

# or use: System -> Preferences -> Screen Resolution:
# it is detected, then once resolution and position are set, restart the
# laptop with it plugged in.

# Fn+F4, Fn+F5 and Fn+F7 usually do not work.

# Or: Ctrl+Alt+F2 to switch to a terminal, then Fn+F7 to switch the video
# output, and Ctrl+Alt+F2 to switch back to the desktop.

# Restore with: xrandr --output LVDS --mode 1280x800
