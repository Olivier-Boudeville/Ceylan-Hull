#!/bin/bash

TIDY=/usr/local/Logiciels/tidy/bin/tidy
TIDY_CONF=/home/sye/Personnel/Projets/WebSites/Common/HTMLTidy/tidy.conf

$TIDY -config $TIDY_CONF $1 1>/dev/null
