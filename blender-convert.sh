#!/bin/sh

usage="Usage: $(basename $0) [-h|--help] FILE_TO_CONVERT: converts the specified file to the glTF 2.0 binary format (*.glb).

  Supported input file formats (extensions are case-independant):
	- glTF 2.0 as JSON (extension: '*.gltf')
	- Collada/DAE (extension: '*.dae')
	- FBX (extension: '*.fbx')
	- IFC (extension: '*.ifc')

  Options:
	-h or --help: displays this help

Note that this script depends on the Ceylan-Snake Blender support (https://github.com/Olivier-Boudeville/Ceylan-Snake/tree/master/blender-support), and that, for an IFC to be converted, the BIM add-on must have already been installed in Blender (see https://blenderbim.org/).
"


if [ "$1" = "-h" ] || [ "$1" = "--help" ]; then

	echo "${usage}"

	exit 0

fi

if [ ! $# -eq 1 ]; then

	echo "  Error, exactly one parameter must be specified.
${usage}" 1>&2

	exit 10

fi


blender="$(which blender)"

if [ ! -x "${blender}" ]; then

	echo "  Error, blender executable not found." 1>&2

	exit 5

fi


blender_support_dir="${CEYLAN_SNAKE}/blender-support"

if [ ! -d "${blender_support_dir}" ]; then

	echo "  Error, the directory of Python importers for Blender ('${blender_support_dir}') could not be found." 1>&2

	exit 8

fi


file_to_convert="$(realpath $1)"

# Regular or symlink:
if [ ! -f "${file_to_convert}" ] && [ ! -L "${file_to_convert}" ]; then

	echo "  Error, specified file '${file_to_convert}' does not exist." 1>&2
	exit 15

fi


conversion_script="${blender_support_dir}/blender_convert.py"

if [ ! -f "${conversion_script}" ]; then

	echo "  Error, conversion script ('${conversion_script}') not found." 1>&2
	exit 35

fi


# For Draco support (see
# http://howtos.esperide.org/ThreeDimensional.html#draco):
#
export BLENDER_EXTERN_DRACO_LIBRARY_PATH=/usr/lib


# Needing to locate for example the blender_snake helper module:
cd "${blender_support_dir}"

LANG=C ${blender} --background --python "${conversion_script}" -- "${file_to_convert}"
