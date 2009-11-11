#!/bin/bash

LESS=`which less  2>/dev/null| grep -v ridiculously 2>/dev/null`
MORE=`which more  2>/dev/null| grep -v ridiculously 2>/dev/null`

displayViewers()
{
     echo "LESS = ${LESS}"
     echo "MORE = ${MORE}"
}

#displayViewers

# Take the best one (watch out the order !):
# ('more' is preferred to 'less', since it handles well accentuated characters)

if [ -x "${LESS}" ]; then
    VIEWER="${LESS}"
fi


if [ -x "${MORE}" ]; then
    VIEWER="${MORE}"
fi


if [ "${VIEWER}" = "${MORE}" ]; then
    # Only the first file is checked:
    FILE_TYPE=`file $1 | awk '{print $2}'`
    if [ "${FILE_TYPE}" == "data" ]; then
        echo "$1 contains binary data (hence not printed)."
        exit 0
    fi   
fi


${VIEWER} $*

