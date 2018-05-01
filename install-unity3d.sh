#!/bin/sh

base_install_dir="$HOME/Software"


USAGE="$(basename $0) [BASE_INSTALL_DIR]: installs current stable version of Unity3D in specified base directory (default: ${base_install_dir}). Note that at least 25 GiB of free space in that directory might be needed."

# Adapted from https://aur.archlinux.org/packages/unity-editor/ and specifically
# https://aur.archlinux.org/cgit/aur.git/tree/PKGBUILD?h=unity-editor.
#
# See also: https://wiki.archlinux.org/index.php/Unity3D


mkdir=$(which mkdir)



if [ -n "$1" ] ; then

	base_install_dir="$1"

	if [ ! -d "${base_install_dir}" ] ; then

		echo "  Error, specified base installation directory '${base_install_dir}' does not exist." 1>&2
		exit 5

	fi

fi


install_dir="${base_install_dir}/Unity3D"

echo "Install directory: ${install_dir}"

${mkdir} -p ${install_dir}


fetch_file()
{

	url=$1
	expected_sha1=$2

	file=$(echo "${url}" | sed 's|^.*\/||1')

	echo "Downloading ${url}, expecting file '${file}' of SHA1 ${expected_sha1}..."

	wget --quiet ${url}

	res=$?

	if [ ! $res -eq 0 ] ; then

		echo "  Error, download of '${url}' failed (code: $res)." 1>&2
		exit 10

	fi

	if [ ! -f "${file}" ] ; then

		echo "  Error, file '${file}', downloaded from '${url}', not found." 1>&2
		exit 15

	fi

	computed_sha1=$(sha1sum "${file}" | sed 's|  .*$||1')

	if [ "${computed_sha1}" != "${expected_sha1}" ] ; then

		echo "  Error, computed SHA1 for file '${file}' (downloaded from '${url}') is ${computed_sha1}, whereas expected one was ${expected_sha1}." 1>&2
		exit 20

	fi

}

version=2017.4.0
build=f1
build_tag=20180501

#pkg_version=${version}${build}+${build_tag}

package_hash=0ec691fce5c2

package_url="http://beta.unity3d.com/download/${package_hash}"


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

#fetch_file ${installer} b379e6df5d9d5f02047d37c3399a2b1bb5168dda

file="UnitySetup-2017.4.0f1"
echo "Got ${file}!"

chmod +x "${file}"

${file}

# No need to go further, it is better done interactively.
# Note: a Python symlink fix may be added.

exit
