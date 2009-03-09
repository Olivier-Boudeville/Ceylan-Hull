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
grep AIGLX /var/log/Xorg.0.log | grep -v '(WW)'
echo

echo "..done"

