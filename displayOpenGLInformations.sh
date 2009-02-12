#!/bin/sh

echo "Getting informations about OpenGL support..."
echo

# First display:
DISPLAY=:0 

echo "  * Hardware-accelerated rendering:"
glxinfo | egrep "direct rendering"
glxinfo | egrep "OpenGL .* string"
echo


echo "  * Graphical controller: "
lspci | grep "VGA" 
echo

echo "  * Installed GL libraries:"
/bin/ls -l /usr/lib/libGL.so*
echo

echo "  * AIGLX status: "
grep AIGLX /var/log/Xorg.0.log
echo


echo "..done"

# rainbow without hardware support: 2598 frames in 5.0 seconds = 517.594 FPS

