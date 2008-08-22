#!/bin/sh 

LANG=C; export LANG


USAGE="Usage: "`dirname $0`" [<install directory>]: downloads, builds and installs a fresh Erlang version in specified directory (if any), or in default directory."


ERLANG_VERSION="R12B-3"
ERLANG_ARCHIVE="otp_src_${ERLANG_VERSION}.tar.gz"
ERLANG_DOWNLOAD_LOCATION="http://erlang.org/download"
ERLANG_MD5="c2e7f0ad54b8fadebde2d94106608d97"


INSTALL_DIR="$1"

if [ -z "${INSTALL_DIR}" ] ; then
	INSTALL_DIR=$HOME/software/Erlang-${ERLANG_VERSION}
fi

echo "Erlang will be installed in ${INSTALL_DIR}."
mkdir -p ${INSTALL_DIR}


ERLANG_TARGET_FILE="${ERLANG_DOWNLOAD_LOCATION}/${ERLANG_ARCHIVE}"

#wget ${ERLANG_TARGET_FILE}

tar xvzf ${ERLANG_ARCHIVE} 
if [ ! $? -eq 0 ] ; then
	echo "  Error while extracting ${ERLANG_ARCHIVE}, quitting." 1>&2
	exit 5
fi	

prefix=${INSTALL_DIR}
mkdir -p ${prefix}

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


echo "  Building Erlang environment..." && ./configure ${CONFIGURE_OPT} --prefix=${prefix} && make && make install && echo "  ...Erlang successfully built"

