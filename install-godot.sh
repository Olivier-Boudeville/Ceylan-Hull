#!/bin/sh

# Use update-aur-installer.sh beforehand if needed.

# Ensure that you have proper, hardware-accelerated OpenGL drivers, otherwise:
# "Your video card driver does not support any of the supported OpenGL
# versions. Please update your drivers or if you have a very old or integrated
# GPU upgrade it."

# To check, one may use: 'glxinfo | grep rendering'.
# Having "direct rendering: Yes" returned shall be sufficient.

# Having instead:
#
# name of display: :0.0
# X Error of failed request:  BadValue (integer parameter out of range for operation)
#  Major opcode of failed request:  151 (GLX)
#  Minor opcode of failed request:  24 (X_GLXCreateNewContext)
#
# means a proper video driver must be installed ('lspci | grep VGA') then search
# for a relevant package in your distribution.

echo "Prefer the godot-bin (2) provider (otherwise avoid overheating)"
yay -Sy godot
