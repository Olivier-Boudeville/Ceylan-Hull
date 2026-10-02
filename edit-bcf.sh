#!/bin/sh

usage="Usage: $(basename $0) BCF_FILE: imports in Bonsai (a BIM plugin of Blender, expected to be already installed) the specified BCF_FILE (whose extension is typically *.bcf or *.bcfzip)."


# Stop script on command error and on unset variable:
set -eu

if [ $# -ne 1 ]; then

    echo "${usage}" >&2

    exit 5

fi


bcf_file="$(realpath "$1")"

if [ ! -f "${bcf_file}" ] && [ ! -L "${bcf_file}" ]; then

    echo "  Error, no '${bcf_file}' BCF file found." >&2

    exit 10

fi


blender_exec="$(which blender 2>/dev/null)"

if [ ! -x "${blender_exec}" ]; then

    echo "  Error, no blender executable found." >&2

    exit 15

fi


# Writing a short Python script as an HERE-document:

tmp_py="$(mktemp)"

cat >"${tmp_py}" <<EOF
import bpy

bcf_filepath = r"${bcf_file}"

print(f"Loading BCF file {bcf_filepath} in Bonsai.")
print("Its content should be available in the 'Scene' -> 'Quality and Coordination' (the icon with two persons) -> Collaboration -> 'BCF Project' panel (generally on the right side of the screen)...\n")

bpy.ops.bim.load_bcf_project(filepath=bcf_filepath)

EOF

# Not blocking:
"${blender_exec}" --python "${tmp_py}" &
