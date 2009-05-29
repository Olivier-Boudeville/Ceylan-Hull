#!/bin/sh 

LANG=C; export LANG


USAGE="Usage: "`basename $0`" [-h|--help] [-c|--cutting-edge] [-d|--doc-install] [-n|--no-download] [<install directory>]: downloads, builds and installs a fresh Erlang version in specified base directory (if any), or in default directory, and add a symbolic link pointing to it from its parent directory.
This script should be run preferably from a location like ~/Software/Erlang.

Options:
    -c or --cutting-edge: use, instead of the latest stable Erlang version, the latest beta version, if any  
    -d or --doc-install: download and install the corresponding documentation as well
    -n or --no-download: do not attempt to download anything, expect that needed files are already available (useful if not having a direct access to the Internet)

Example: 
  install-erlang.sh --cutting-edge --doc-install --no-download
    will install latest available version of Erlang, with its documentation, in the ~/Software/Erlang directory, without downloading anything,  
      - or -
  install-erlang.sh --doc-install ~/my-directory
    will install current official stable version of Erlang, with its documentation, in the ~/my-directory/Erlang base directory, by downloading Erlang archives from the Internet 
"

# By default, will download files:
do_download=0

# By default, will not manage the documentation:
do_manage_doc=1


ERLANG_DOWNLOAD_LOCATION="http://erlang.org/download"


ERLANG_VERSION="R13B"

# MD5 codes are not used currently:
ERLANG_MD5="6d8c256468a198458b9f08ba6aa1a384"



# Read all known options:

token_eaten=0

while [ $token_eaten -eq 0 ] ; do

	read_parameter="$1"
	#echo "read_parameter = $read_parameter"
	
	token_eaten=1

	if [ "$1" = "-h" -o "$1" = "--help" ] ; then

		echo "$USAGE"
		exit
	
	fi



	if [ "$1" = "-c" -o "$1" = "--cutting-edge" ] ; then

		echo "Warning: not using latest beta (unstable) version of Erlang, as the corresponding stable version is more recent."
		
		#echo "Warning: using latest beta (unstable) version of Erlang."
		#ERLANG_VERSION="R13A"
		#ERLANG_MD5="76804ff9c18710184cf0c0230a0443fc"
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

	install_dir="$HOME/Software/Erlang/Erlang-${ERLANG_VERSION}"
	echo "Using default installation directory '$install_dir'."

else

	install_dir="$read_parameter/Erlang/Erlang-${ERLANG_VERSION}"
	echo "Using '$install_dir' as installation directory."
	
fi


#echo "do_download = $do_download"
#echo "do_manage_doc = $do_manage_doc"



ERLANG_SRC_PREFIX="otp_src_${ERLANG_VERSION}"
ERLANG_SRC_ARCHIVE="${ERLANG_SRC_PREFIX}.tar.gz"


ERLANG_DOC_PREFIX="otp_doc_html_${ERLANG_VERSION}"
ERLANG_DOC_ARCHIVE="${ERLANG_DOC_PREFIX}.tar.gz"


if [ ! -e "/usr/include/ncurses.h" ] ; then

	echo "  Error, the libncurses headers cannot be found, whereas they are needed for the build. 
Use for instance 'apt-get install libncurses5-dev'." 1>&2

	exit 5
fi


echo "Erlang version ${ERLANG_VERSION} will be installed in ${install_dir}."
mkdir -p ${install_dir}



if [ $do_download -eq 0 ] ; then

	ERLANG_TARGET_SRC_URL="${ERLANG_DOWNLOAD_LOCATION}/${ERLANG_SRC_ARCHIVE}"
		
	wget=`which wget`
	
	if [ ! -x "${wget}" ] ; then
		
		echo "  Error, no wget tool found, quitting." 1>&2
		exit 10
	
	fi

	echo "Downloading now ${ERLANG_TARGET_SRC_URL}"
	${wget} ${ERLANG_TARGET_SRC_URL} 1>/dev/null 2>&1
	
	if [ ! $? -eq 0 ] ; then
		echo "  Error while downloading ${ERLANG_TARGET_SRC_URL}, quitting." 1>&2
		exit 15
	fi	


	ERLANG_TARGET_DOC_URL="${ERLANG_DOWNLOAD_LOCATION}/${ERLANG_DOC_ARCHIVE}"

	if [ $do_manage_doc -eq 0 ] ; then
	
		
		echo "Downloading now ${ERLANG_TARGET_DOC_URL}"
		${wget} ${ERLANG_TARGET_DOC_URL} 1>/dev/null 2>&1
	
		if [ ! $? -eq 0 ] ; then
			echo "  Error while downloading ${ERLANG_TARGET_DOC_URL}, quitting." 1>&2
			exit 16
		fi	
	
	fi
	

else

	if [ ! -f "${ERLANG_SRC_ARCHIVE}" ] ; then
	
		echo "  Error, Erlang source archive (${ERLANG_SRC_ARCHIVE}) could not be found, and no download was requested." 1>&2
		exit 20
		
	fi


	if [ $do_manage_doc -eq 0 ] ; then

		if [ ! -f "${ERLANG_DOC_ARCHIVE}" ] ; then
	
			echo "  Error, Erlang documentation archive (${ERLANG_DOC_ARCHIVE}) could not be found, and no download was requested." 1>&2
			exit 21
		
		fi
	fi
	
fi

if [ -e "${ERLANG_SRC_PREFIX}" ] ; then

	/bin/rm -rf "${ERLANG_SRC_PREFIX}"
	
fi

tar xvzf ${ERLANG_SRC_ARCHIVE}
 
if [ ! $? -eq 0 ] ; then
	echo "  Error while extracting ${ERLANG_SRC_ARCHIVE}, quitting." 1>&2
	exit 50
fi	

prefix=${install_dir}
mkdir -p ${prefix}


initial_path=`pwd`

# Starting from the source tree:

cd otp_src_${ERLANG_VERSION}


# See also:
# http://www.erlang-consulting.com/thesis/tcp_optimisation/tcp_optimisation.html
# for feature impact on performances.

# SSL by default is not supposed to be available. Hence for example the crypto
# module will not be available. 
# Add for example '--with-ssl=/usr/bin' to activate it.
# crypto could be still disabled due to:
# 'OpenSSL is configured for kerberos but no krb5.h found'.
BUILD_OPT="--enable-threads --enable-smp-support --enable-kernel-poll --enable-hipe"


echo "  Building Erlang environment..." && ./configure ${CONFIGURE_OPT} --prefix=${prefix} && make && make install


if [ $? -eq 0 ] ; then

	echo "  Erlang successfully built and installed in ${prefix}. 
The build tree, in the otp_src_${ERLANG_VERSION} directory, can be safely removed."

else

	echo "  Error, the Erlang build failed." 1>&2
	exit 60
	
fi

cd ..


# Go to the build (not source) tree:


cd ${install_dir}/..

# Ex: we are in $HOME/Software/Erlang now.


# Sets as current:
if [ -e Erlang-current-install ] ; then

	/bin/rm -f Erlang-current-install

fi
	
/bin/ln -sf Erlang-${ERLANG_VERSION} Erlang-current-install



if [ $do_manage_doc -eq 0 ] ; then

	ERLANG_DOC_ROOT="Erlang-${ERLANG_VERSION}-documentation"
	
	if [ -e "${ERLANG_DOC_ROOT}" ] ; then

		/bin/rm -rf "${ERLANG_DOC_ROOT}"
	
	fi

	mkdir "${ERLANG_DOC_ROOT}" 
	
	cd "${ERLANG_DOC_ROOT}"
	
	tar xvzf ${initial_path}/${ERLANG_DOC_ARCHIVE}
 
 
	if [ ! $? -eq 0 ] ; then
		echo "  Error while extracting ${ERLANG_DOC_ARCHIVE}, quitting." 1>&2
		exit 70
	fi	

	cd .. 
	
	# Sets as current:
	if [ -e Erlang-current-install ] ; then

		/bin/rm -f Erlang-current-documentation

	fi
	
	ln -sf ${ERLANG_DOC_ROOT} Erlang-current-documentation

	echo "Erlang documentation installed."
	
fi

