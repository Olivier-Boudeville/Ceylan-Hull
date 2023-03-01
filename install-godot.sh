#!/bin/sh

# Enable to use the AUR:
#use_yay=0
use_yay=1

# For a custom install (we prefer that approach):
godot_version="4.0"
dotnet_version="6.0"


usage="$(basename $0) [-h|--help]: installs the Godot ${godot_version} .NET version according to Ceylan's conventions.

The Mono support must be already available (e.g. on Arch run 'pacman --needed -Sy dotnet-sdk-${dotnet_version} mono mono-msbuild').
"

# Ensure that you have proper, hardware-accelerated OpenGL drivers, otherwise:
# "Your video card driver does not support any of the supported OpenGL
# versions. Please update your drivers or if you have a very old or integrated
# GPU upgrade it."
#
# To check, one may use: 'glxinfo | grep rendering'.
# Having "direct rendering: Yes" returned shall be sufficient.
#
# Having instead:
#
# name of display: :0.0
# X Error of failed request: BadValue (integer parameter out of range for
# operation)
#  Major opcode of failed request:  151 (GLX)
#  Minor opcode of failed request:  24 (X_GLXCreateNewContext)
#
# means a proper video driver must be installed ('lspci | grep VGA') then search
# for a relevant package in your distribution.


set -Eeo pipefail

if [ "$1" = "-h" ] || [ "$1" = "--help" ]; then

	echo "${usage}"

	exit

fi



if [ $use_yay -eq 0 ]; then

	# Use update-aur-installer.sh beforehand if needed.

	# See also https://aur.archlinux.org/packages/godot-mono

	#yay -Sy godot-mono

	echo "Prefer the godot-mono-bin (2) provider (otherwise avoid overheating)"
	yay -Sy godot-mono-bin

else

	base_dir="${HOME}/Software/Godot"

	mkdir -p "${base_dir}"

	cd "${base_dir}"

	godot_base_name="Godot_v${godot_version}-stable_mono_linux_x86_64"
	godot_root="${godot_base_name}"

	if [ -d "${godot_root}" ]; then

		echo "  Error, a '$(pwd)/${godot_root}' directory already exists, remove it first." 1>&2
		exit 40

	fi


	godot_archive="${godot_base_name}.zip"

	if [ -f "${godot_archive}" ]; then

		echo "  (reusing supposedly correct archive '${godot_archive}')"

	else

		godot_download_base="https://downloads.tuxfamily.org/godotengine/${godot_version}/mono"
		godot_url="${godot_download_base}/${godot_archive}"

		if ! wget --no-verbose "${godot_url}"; then

			echo "  Error, the download of Godot archive (from '${godot_url}') failed." 1>&2
			exit 15

		fi

	fi

	unzip -q "${godot_archive}"

	ln -sf --no-target-directory "${godot_root}" godot-current-install

	cd godot-current-install

	# Almost the same name as ${godot_base_name} (but different):
	godot_exec="Godot_v${godot_version}-stable_mono_linux.x86_64"

	if [ ! -f "${godot_exec}" ]; then

		echo "  Error, no Godot executable found (no '${godot_exec}')." 1>&2
		exit 20

	fi

	ln -s "${godot_exec}" godot

	echo " Godot ${godot_version} .NET version successfully installed in '${godot_root}'. Ensure that the '${base_dir}/godot-current-install' directory is in your PATH, then execute 'godot' to run it."

fi
