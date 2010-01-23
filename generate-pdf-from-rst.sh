#!/bin/sh

source_file="$1"

if [ ! -f "${source_file}" ] ; then

	echo "  Error, source file ${source_file} not found." 1>&2
	exit 10
	
fi

rule_file="$CEYLAN_SRC/doc/GNUmakerules-docutils.inc"

if [ ! -f "${rule_file}" ] ; then

	echo "  Error, rule file to generate PDF ${rule_file} not found." 1>&2
	exit 11
	
fi

target_file=`echo ${source_file}|sed 's|.rst$|.pdf|1'`

echo "
Generating now ${target_file} from ${source_file}...
" && make -f "${rule_file}" "${target_file}" && echo "Generation succeeded!"

