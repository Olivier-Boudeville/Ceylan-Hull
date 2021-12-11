#!/bin/sh

usage="Usage: $(basename $0) [-h|--help] FILE_TO_IMPORT: imports the specified file into a newly-launched instance of Blender that will automatically focus on the loaded content.

More precisely, allows to import directly in Blender various file formats from the command-line, rather than doing it interactively. Takes care of checking file availability and extension, launching Blender, disabling the splash screen, removing the default primitives (cube, light, camera, collection), importing specified file without having to access menu with a cumbersome dialog requiring to go through the whole filesystem, and focusing the viewpoint onto the loaded objects.

  Supported file formats (extension are case-independant):
	- glTF 2.0 (extensions: '*.gltf'/'*.glb')
	- Collada/DAE (extension: '*.dae')
	- FBX (extension: '*.fbx')
	- IFC (extension: '*.ifc')

  Options:
	-h or --help: displays this help

Note that this script depends on the Ceylan-Snake Blender importer (https://github.com/Olivier-Boudeville/Ceylan-Snake/tree/master/blender-importers), and that, for an IFC to be imported, the BIM add-on must have already been installed in Blender (see https://blenderbim.org/).
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


python_importers_dir="${CEYLAN_SNAKE}/blender-importers"

if [ ! -d "${python_importers_dir}" ]; then

	echo "  Error, the directory of Python importers for Blender ('${python_importers_dir}') could not be found." 1>&2

	exit 8

fi


file_to_import="$1"

# Regular or symlink:
if [ ! -f "${file_to_import}" ] && [ ! -L "${file_to_import}" ]; then

	echo "  Error, specified file '${file_to_import}' does not exist." 1>&2
	exit 15

fi

# Now a single Python import script is used, rather than one per file format:
#ext="$(echo "${file_to_import}" | sed 's|^.*\.||1' | tr '[:upper:]' '[:lower:]')"
#echo "Extension: '${ext}'."

import_script="${python_importers_dir}/blender_import.py"

if [ ! -f "${import_script}" ]; then

		echo "  Error, import script ('${import_script}') not found." 1>&2
		exit 35

	fi

${blender} --python "${import_script}" -- "${file_to_import}"
