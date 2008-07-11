#!/bin/sh 

LANG=C; export LANG

ERLANG_VERSION="R12B-3"
ERLANG_ARCHIVE="otp_src_${ERLANG_VERSION}.tar.gz"
ERLANG_DOWNLOAD_LOCATION="http://erlang.org/download"
ERLANG_MD5="c2e7f0ad54b8fadebde2d94106608d97"


ERLANG_TARGET_FILE="${ERLANG_DOWNLOAD_LOCATION}/${ERLANG_ARCHIVE}"

#wget ${ERLANG_TARGET_FILE}

tar xvzf ${ERLANG_ARCHIVE}

prefix=$HOME/Logiciels/erlang-${ERLANG_VERSION}
mkdir -p ${prefix}

cd otp_src_${ERLANG_VERSION}


# See also:
# http://www.erlang-consulting.com/thesis/tcp_optimisation/tcp_optimisation.html
# for feature impact on performances.

BUILD_OPT="--enable-threads --enable-smp-support --enable-kernel-poll --enable-hipe"

echo "Build Erlang environment..." && ./configure ${BUILD_OPT} --prefix=${prefix} && make && make install && echo "...Erlang successfully built"

