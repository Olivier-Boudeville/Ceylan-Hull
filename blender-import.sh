#!/bin/sh

read_only_opt="--read-only"

usage="Usage: $(basename $0) [-h|--help] [${read_only_opt}] FILE_TO_IMPORT: imports the specified file into a newly-launched instance of Blender that will automatically focus on the loaded content.

More precisely, allows to import directly in Blender various file formats from the command-line, rather than doing it interactively. Takes care of checking file availability and extension, launching Blender, disabling the splash screen, removing the default primitives (cube, light, camera, collection), importing specified file without having to access menu with a cumbersome dialog requiring to go through the whole filesystem, and focusing the viewpoint onto the loaded objects.

  Supported file formats (extensions are case-independent):
	- glTF 2.0 (extensions: '*.gltf'/'*.glb')
	- Collada/DAE (extension: '*.dae')
	- FBX (extension: '*.fbx')
	- OBJ (extension: '*.obj')
	- IFC (extension: '*.ifc')

  Options:
    ${read_only_opt}: forces read-only mode
	-h or --help: displays this help

Note that this script depends on the Ceylan-Snake Blender importer (https://github.com/Olivier-Boudeville/Ceylan-Snake/tree/master/blender-support), and that, for an IFC to be imported, the BIM add-on must have already been installed in Blender (see https://bonsaibim.org/).
"


if [ "$1" = "-h" ] || [ "$1" = "--help" ]; then

	echo "${usage}"

	exit 0

fi


read_only=1

if [ "$1" = "${read_only_opt}" ]; then

	#echo "(read-only mode enabled)"
	echo "(read-only mode enabled, yet ignored as Blender would fail by trying to interpret it)"

	read_only=0

	# Chosen to be the same:
	#blender_read_only_opt="${read_only_opt}"

	shift

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


# We will change the current directory:
file_to_import="$(realpath $1)"

# Regular or symlink:
if [ ! -f "${file_to_import}" ] && [ ! -L "${file_to_import}" ]; then

	echo "  Error, specified file '${file_to_import}' does not exist." 1>&2
	exit 15

fi

# Now a single Python import script is used, rather than one per file format:
#ext="$(echo "${file_to_import}" | sed 's|^.*\.||1' | tr '[:upper:]' '[:lower:]')"
#echo "Extension: '${ext}'."


import_script="${blender_support_dir}/blender_import.py"

if [ ! -f "${import_script}" ]; then

	echo "  Error, import script ('${import_script}') not found." 1>&2
	exit 35

fi


# For Draco support, if ever needed (see
# http://howtos.esperide.org/ThreeDimensional.html#draco):
#
export BLENDER_EXTERN_DRACO_LIBRARY_PATH=/usr/lib


# Needing to locate for example the blender_snake helper module:
cd "${blender_support_dir}"


#echo LANG=C "${blender}" --python "${import_script}" ${blender_read_only_opt} -- "${file_to_import}"

LANG=C "${blender}" --python "${import_script}" ${blender_read_only_opt} -- "${file_to_import}"
