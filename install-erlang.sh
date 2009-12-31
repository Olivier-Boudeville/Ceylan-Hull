#!/bin/sh

LANG=C; export LANG


erlang_version="R13B03"

erlang_md5="411fcb29f0819973f71e28f6b56d9948"


usage="Usage: "`basename $0`" [-h|--help] [-c|--cutting-edge] [-d|--doc-install] [-n|--no-download] [<base install directory>]: downloads, builds and installs a fresh Erlang version in specified base directory (if any), or in default directory, and in this case adds a symbolic link pointing to it from its parent directory so that Erlang-current-install always points to the latest installed version.

If no base install directory is specified, then if this script is run by root Erlang will be installed into /usr/local (i.e. system-wide), otherwise it will be installed into ~/Software/Erlang/Erlang-${erlang_version}/.

Options:
    -c or --cutting-edge: use, instead of the latest stable Erlang version, the latest beta version, if any
    -d or --doc-install: download and install the corresponding documentation as well
    -n or --no-download: do not attempt to download anything, expect that needed files are already available (useful if not having a direct access to the Internet)

Example:
  install-erlang.sh --cutting-edge --doc-install --no-download
    will install latest available version of Erlang, with its documentation, in the ~/Software/Erlang directory, without downloading anything,
	  - or -
  install-erlang.sh --doc-install ~/my-directory
    will install current official stable version of Erlang, with its documentation, in the ~/my-directory/Erlang/Erlang-${erlang_version} base directory, by downloading Erlang archives from the Internet

For Debian-based distributions, you should preferably run beforehand, as root: 'apt-get update && apt-get install gcc make libncurses5-dev openssl libssl-dev', otherwise for example the crypto module might not be available.
"

# By default, will download files:
do_download=0


# By default, will not manage the documentation:
do_manage_doc=1


# By default, the Erlang build tree will be removed:
do_remove_build_tree=0


erlang_download_location="http://erlang.org/download"



# Read all known options:

token_eaten=0

# By default, use an installation prefix:
use_prefix=0

while [ $token_eaten -eq 0 ] ; do

	read_parameter="$1"
	#echo "read_parameter = $read_parameter"

	token_eaten=1

	if [ "$1" = "-h" -o "$1" = "--help" ] ; then

		echo "$usage"
		exit

	fi


	if [ "$1" = "-c" -o "$1" = "--cutting-edge" ] ; then

		echo "Warning: not using latest beta (unstable) version of Erlang, as the corresponding stable version is more recent."

		#echo "Warning: using latest beta (unstable) version of Erlang."
		#erlang_version="R13A"
		#erlang_md5="76804ff9c18710184cf0c0230a0443fc"
		token_eaten=0

	fi


	if [ "$1" = "-d" -o "$1" = "--doc-install" ] ; then

		echo "Will manage the corresponding documentation."
		do_manage_doc=0
		token_eaten=0

	fi


	if [ "$1" = "-n" -o "$1" = "--no-download" ] ; then

		echo "No file will be downloaded."
		do_download=1
		token_eaten=0

	fi


	if [ -n "$read_parameter" ] ; then
		shift
	fi

done




# Then check whether one parameter remains:

if [ -z "$read_parameter" ] ; then

	# Here no base installation directory was specified:

	if [ `id -u` -eq 0 ] ; then

		# Run as root, no prefix specified, thus:
		use_prefix=1

		prefix="/usr/local"
		echo "Run as root, thus using default system installation directory."

	else

		prefix="$HOME/Software/Erlang/Erlang-${erlang_version}"
		echo "Not run as root, thus using default installation directory '$prefix'."

	fi

else

	prefix="$read_parameter/Erlang/Erlang-${erlang_version}"
	echo "Using '$prefix' as installation directory."

fi


#echo "do_download = $do_download"
#echo "do_manage_doc = $do_manage_doc"



erlang_src_prefix="otp_src_${erlang_version}"
erlang_src_archive="${erlang_src_prefix}.tar.gz"


erlang_doc_prefix="otp_doc_html_${erlang_version}"
erlang_doc_archive="${erlang_doc_prefix}.tar.gz"


if [ ! -e "/usr/include/ncurses.h" ] ; then

	echo "  Error, the libncurses headers cannot be found, whereas they are needed for the build.
		Use for instance 'apt-get install libncurses5-dev' (other packages should preferably be also installed beforehand, see help)." 1>&2

	exit 5

fi



if [ $do_download -eq 0 ] ; then

	erlang_target_src_url="${erlang_download_location}/${erlang_src_archive}"

	wget=`which wget`

	if [ ! -x "${wget}" ] ; then

		echo "  Error, no wget tool found, quitting." 1>&2
		exit 10

	fi

	echo "  Downloading now ${erlang_target_src_url}"
	${wget} ${erlang_target_src_url} 1>/dev/null 2>&1

	if [ ! $? -eq 0 ] ; then
		echo "  Error while downloading ${erlang_target_src_url}, quitting." 1>&2
		exit 15
	fi


	erlang_target_doc_url="${erlang_download_location}/${erlang_doc_archive}"

	if [ $do_manage_doc -eq 0 ] ; then


		echo "  Downloading now ${erlang_target_doc_url}"
		${wget} ${erlang_target_doc_url} 1>/dev/null 2>&1

		if [ ! $? -eq 0 ] ; then
			echo "  Error while downloading ${erlang_target_doc_url}, quitting." 1>&2
			exit 16
		fi

	fi


else

	if [ ! -f "${erlang_src_archive}" ] ; then

		echo "  Error, Erlang source archive (${erlang_src_archive}) could not be found from current directory ('"`pwd`"'), and no download was requested." 1>&2
		exit 20

	fi


	if [ $do_manage_doc -eq 0 ] ; then

		if [ ! -f "${erlang_doc_archive}" ] ; then

			echo "  Error, Erlang documentation archive (${erlang_doc_archive}) could not be found, and no download was requested." 1>&2
			exit 21

		fi
	fi

fi


md5sum=`which md5sum`

if [ ! -x "${md5sum}" ] ; then

	echo "  Warning: no md5sum tool found, therefore MD5 code will not be checked."

else

	md5_res=`${md5sum} ${erlang_src_archive}`

	computed_md5=`echo ${md5_res}| awk '{printf $1}'`

	if [ "${computed_md5}" = "${erlang_md5}" ] ; then
		echo "MD5 sum for Erlang source archive matches."
	else
		echo "Error, MD5 sums not matching for Erlang source archive: expected '${erlang_md5}', computed '${computed_md5}'." 1>&2
		exit 25
	fi

fi


if [ $use_prefix -eq 0 ] ; then

	echo "Erlang version ${erlang_version} will be installed in ${prefix}."

	mkdir -p ${prefix}

	if [ -e "${erlang_src_prefix}" ] ; then

		/bin/rm -rf "${erlang_src_prefix}"

	fi

else

	echo "Erlang version ${erlang_version} will be installed in the system tree."

fi


tar xvzf ${erlang_src_archive}

if [ ! $? -eq 0 ] ; then
	echo "  Error while extracting ${erlang_src_archive}, quitting." 1>&2
	exit 50

fi

initial_path=`pwd`

# Starting from the source tree:

cd otp_src_${erlang_version}


# See also:
# http://www.erlang-consulting.com/thesis/tcp_optimisation/tcp_optimisation.html
# for feature impact on performances.

# SSL by default is not supposed to be available. Hence for example the crypto
# module will not be available.
# Add below for example '--with-ssl=/usr/bin' to activate it.
# crypto could be still disabled due to:
# 'OpenSSL is configured for kerberos but no krb5.h found'.
configure_opt="--enable-threads --enable-smp-support --enable-kernel-poll --enable-hipe"

if [ $use_prefix -eq 0 ] ; then
	prefix_opt="--prefix=${prefix}"
fi


echo "  Building Erlang environment..." && ./configure ${configure_opt} ${prefix_opt} && make && make install


if [ $? -eq 0 ] ; then

	echo "  Erlang successfully built and installed in ${prefix}.
		The build tree, in the otp_src_${erlang_version} directory, can be safely removed."

else

	echo "  Error, the Erlang build failed." 1>&2
	exit 60

fi

if [ $use_prefix -eq 0 ] ; then

    # Go to the install (not source) tree:
	cd ${prefix}/..

    # Ex: we are in $HOME/Software/Erlang now.


    # Sets as current:
	if [ -e Erlang-current-install ] ; then

		/bin/rm -f Erlang-current-install

	fi

	/bin/ln -sf Erlang-${erlang_version} Erlang-current-install

fi



if [ $do_manage_doc -eq 0 ] ; then

	if [ $use_prefix -eq 0 ] ; then

		cd $prefix/..

	else

		cd /usr/share

	fi

	erlang_doc_root="Erlang-${erlang_version}-documentation"

	if [ -e "${erlang_doc_root}" ] ; then

		/bin/rm -rf "${erlang_doc_root}"

	fi

	mkdir "${erlang_doc_root}"

	cd "${erlang_doc_root}"

	tar xvzf ${initial_path}/${erlang_doc_archive}


	if [ ! $? -eq 0 ] ; then
		echo "  Error while extracting ${erlang_doc_archive}, quitting." 1>&2
		exit 70
	fi

	cd ..

	# Sets as current:
	if [ -e Erlang-current-install ] ; then

		/bin/rm -f Erlang-current-documentation

	fi

	ln -sf ${erlang_doc_root} Erlang-current-documentation

	echo "Erlang documentation successfully installed."

fi



if [ $do_remove_build_tree -eq 0 ] ; then

	/bin/rm -rf ${initial_path}/otp_src_${erlang_version}

else

	echo "(the otp_src_${erlang_version} build directory can be safely removed if wanted)."

fi


echo
echo "The Erlang environment was successfully installed in ${prefix}."
