#!/bin/sh

usage="Usage: $(basename $0) [-h|--help] FILE_TO_IMPORT: imports specified file into a newly-launched instance of Blender.
  Supported file formats:
	- glTF 2.0 (extension: '*.gltf')
	- IFC (extension: '*.ifc')

Note that this script depends on Ceylan-Snake (see http://snake.esperide.org)
"

# -h or --help: displays this help


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

ext="$(echo "${file_to_import}" | sed 's|^.*\.||1')"
#echo "Extension: '${ext}'."


if [ "${ext}" = "gltf" ]; then

	gltf_script="${python_importers_dir}/blender_import_gltf.py"

	if [ ! -f "${gltf_script}" ]; then

		echo "  Error, import script for glTF 2.0 ('${gltf_script}') not found." 1>&2
		exit 30

	fi

	${blender} --python "${gltf_script}" -- "${file_to_import}"

elif [ "${ext}" = "ifc" ]; then


	ifc_script="${python_importers_dir}/blender_import_ifc.py"

	if [ ! -f "${ifc_script}" ]; then

		echo "  Error, import script for IFC ('${ifc_script}') not found." 1>&2
		exit 35

	fi

	${blender} --python "${ifc_script}" -- "${file_to_import}"

else

	echo "  Error, unsupported file format (extension: '${ext}')." 1>&2
	exit 50

fi
