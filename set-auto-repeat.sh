#!/bin/sh

usage="$(basename $0): enables the keyboard auto-repeat mode (to issue multiple characters in case of longer keypresses)."

/bin/xset r on

# Ex: xset r rate 190 35
