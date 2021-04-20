#!/bin/sh

usage="Usage: $(basename $0) EXPR: prevents special characters in EXPR from being interpreted by tools like sed.
  Example: '$(basename $0) eee/dd/f' should output eee\/dd\/f"

sed=/bin/sed

if [ ! -x "${sed}" ]; then
	sed=/usr/bin/sed
fi


if [ $# != 1 ]; then
	echo "Error, exactly one parameter expected.
${usage}" 1>&2
	exit 5
fi


# Replaces '/' by '\/':

#echo $1 | ${sed} 's/\//\\\//g'
echo $1 | ${sed} 's|/|\\/|g'
