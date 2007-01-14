#!/bin/sh

CONF_FILE="~/tidy.conf"

echo "Tyding $1"
tidy -config ${CONF_FILE} -m $1

