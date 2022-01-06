#!/bin/sh

# Unity (LTS) versions are listed in https://unity3d.com/unity/qa/lts-releases,
# yet we prefer to stick to the latest (non-necessarily LTS) one.

echo "Now the safest way to install Unity3D on GNU/Linux seems to use directly the Unity Hub, by signing up and connecting to https://unity3d.com/get-unity/update (associate in your browser the /usr/bin/unityhub executable to unityhub://)."

echo "This script has thus been disabled, and just stops here." 1>&2

exit 5


# This does *not* correspond to the (Linux) "Unity Accelerator" that can be
# downloaded from there (ex: unity-accelerator-app-v1.0.941+g6b39b61.AppImage).



#version=2017.4.0
version=2020.3.25

build=f1

# Not relevant: build_tag=20180501

# To be updated here once first established:
installer_sha1=""

# Adapted from https://aur.archlinux.org/packages/unity-editor/ and specifically
# https://aur.archlinux.org/cgit/aur.git/tree/PKGBUILD?h=unity-editor.
#
# See also: https://wiki.archlinux.org/index.php/Unity3D
#
# The safest way should by to use the Unity Hub, yet it does not seem maintained
# in the AUR: https://aur.archlinux.org/packages/unityhub/

# So now it is done thanks to the "Unity Accelerator" (see
# https://accelerator.cloud.unity3d.com/api/v1/accelerator/download/installer?target_os=linux&download_location=lts-releases), which is a standalone AppImage.


#pkg_version=${version}${build}+${build_tag}

#package_hash=0ec691fce5c2

#package_url="http://beta.unity3d.com/download/${package_hash}"


base_install_dir="${HOME}/Software"


usage="Usage: $(basename $0) [BASE_INSTALL_DIR]: installs the current stable version of Unity3D (version ${version}, build ${build}) in the specified base directory (default: '${base_install_dir}'). Note that at least 25 GiB of free space in that directory might be needed."


mkdir="$(which mkdir 2>/dev/null)"


if [ -n "$1" ]; then

	base_install_dir="$1"

	if [ ! -d "${base_install_dir}" ]; then

		echo "  Error, specified base installation directory '${base_install_dir}' does not exist." 1>&2
		exit 5

	fi

fi


install_dir="${base_install_dir}/Unity3D"

echo "Install directory: ${install_dir}"

${mkdir} -p "${install_dir}"


# Downloads the file of specified URL and optional SHA1. The first time this
# file is downloaded, no SHA1 shall be set; it will be then reported, and is to
# be recorded at the top of this script.
#
fetch_file()
{

	url="$1"
	expected_sha1="$2"

	file="$(echo "${url}" | sed 's|^.*\/||1')"

	if [ -z "${expected_sha1}" ]; then
		echo "Downloading '${url}' (no SHA1 specified)..."
	else
		echo "Downloading '${url}', expecting file '${file}' of SHA1 ${expected_sha1}..."
	fi

	wget --quiet "${url}"

	res=$?

	if [ ! ${res} -eq 0 ]; then

		echo "  Error, download of '${url}' failed (code: ${res})." 1>&2
		exit 10

	fi

	if [ ! -f "${file}" ]; then

		echo "  Error, file '${file}', downloaded from '${url}', not found." 1>&2
		exit 15

	fi

	computed_sha1="$(sha1sum "${file}" | sed 's|  .*$||1')"

	if [ -z "${expected_sha1}" ]; then

		echo "Computed SHA1 for '${url}': '${computed_sha1}'; please update the 'installer_sha1' variable accordingly in script."

	else

		if [ "${computed_sha1}" != "${expected_sha1}" ]; then

			echo "  Error, computed SHA1 for file '${file}' (downloaded from '${url}') is ${computed_sha1}, whereas expected one was ${expected_sha1}." 1>&2
			exit 20

		fi

	fi

}





build_dependencies="gtk2 libsoup libarchive"

strict_dependencies="desktop-file-utils xdg-utils gcc-libs lib32-gcc-libs gconf libgl glu nss libpng12 libxtst libpqxx npm"


enabled_optional_elements="unity-editor-doc unity-editor-standardassets unity-editor-example unity-editor-android unity-editor-webgl unity-editor-windows "

disabled_optional_elements="unity-editor-ios unity-editor-mac unity-editor-facebook"

echo "build_dependencies = ${build_dependencies}"
echo "strict_ = ${strict_dependencies}"
echo "enabled_optional_elements = ${enabled_optional_elements}"

all_dependencies="${build_dependencies} ${strict_dependencies}"

#sudo pacman --noconfirm --needed -Sy ${all_dependencies}


installer="${package_url}/UnitySetup-${version}${build}"

#installer_sha1="b379e6df5d9d5f02047d37c3399a2b1bb5168dda"
installer_sha1=""

fetch_file "${installer}" "${installer_sha1}"

file="UnitySetup-${version}${build}"
echo "Got ${file}!"

chmod +x "${file}"

${file}

# No need to go further, it is better done interactively.
# Note: a Python symlink fix may be added.

exit
