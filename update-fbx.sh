#!/bin/sh

usage="Usage: $(basename $0) [-h|--help] FBX_FILE: updates the specified FBX file so that it adopts a (hopefully) more recent version thereof (currently: FBX 7.3), typically able to be loaded by tools like Blender.

Relies on the Autodesk FBX Converter.

See https://howtos.esperide.org/ThreeDimensional.html#autodesk-converter for more information.
"

if [ ! $# -eq 1 ]; then

	echo "  Error, exactly one parameter expected.
${usage}" 1>&2

	exit 10

fi


if [ "$1" = "-h" ] || [ "$1" = "--help" ]; then

	echo " ${usage}"

	exit

fi


base_dir="$HOME/.wine/drive_c/Program Files/Autodesk/FBX/FBX Converter/2013.3/bin"

converter="$(PATH=${base_dir}:${PATH} which FbxConverter.exe 2>/dev/null)"

if [ ! -x "${converter}" ]; then

	echo "  Error, no Autodesk FBX Converter (searched in PATH and in '${base_dir}')." 1>&2

	exit 15

fi


source_fbx="$1"

if [ ! -f "${source_fbx}" ]; then

	echo "  Error, specified FBX '${source_fbx}' does not exist." 1>&2

	exit 20

fi



tmp_fbx=".tmp.$(basename $0).fbx"

/bin/mv -f "${source_fbx}" "${tmp_fbx}"

target_fbx="${source_fbx}"

echo " Updating in-place '${source_fbx}'..."

if "${converter}" "${tmp_fbx}" "${target_fbx}" /v /sffFBX /dffFBX /e /f201300; then

	echo "File '${target_fbx}' has been successfully updated."

else

	echo "Failed to update '${target_fbx}', previous version restored." 1>&2

	exit 50

fi
