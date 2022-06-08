#!/bin/sh

usage="$(basename $0): displays information regarding the local OpenGL support."

echo "Getting informations about OpenGL support..."
echo


# Not specifying (explicitly) the display to use, as this convention may change
# from a distro to another, and may lead to errors like 'Invalid
# MIT-MAGIC-COOKIE-1 keyError: unable to open display :0:'.

# First display:
#DISPLAY=:0
#DISPLAY=:1

echo "  * Hardware-accelerated rendering:"
glxinfo="$(which glxinfo 2>/dev/null)"


if [ ! -x "${glxinfo}" ]; then

	echo "  Error, glxinfo tool not found. Run for example: 'install-arch-package.sh glxinfo'." 1>&2
	exit 5

fi

${glxinfo} | egrep "direct rendering"
${glxinfo} | egrep "OpenGL .* string"

echo


echo "  * Graphical controller: "
lspci | grep "VGA"
echo

echo "  * Installed GL libraries:"
/bin/ls -l /usr/lib/libGL.so* /usr/lib/x86_64-linux-gnu/libGL.so* 2>/dev/null
echo

echo "  * AIGLX status: "
grep AIGLX /var/log/Xorg.0.log | grep -v '(WW)'
echo

echo "...done"
