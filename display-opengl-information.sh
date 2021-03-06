#!/bin/sh

usage="$(basename $0): displays information regarding the local OpenGL support."

echo "Getting informations about OpenGL support..."
echo

# First display:
DISPLAY=:0

echo "  * Hardware-accelerated rendering:"
GLXINFO=$(which glxinfo 2>/dev/null)


if [ ! -x "$GLXINFO" ]; then

	echo "  Error, glxinfo tool not found. Run for example: 'yaourt glxinfo'" 1>&2
	exit 5

fi

$GLXINFO | egrep "direct rendering"
$GLXINFO | egrep "OpenGL .* string"

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
