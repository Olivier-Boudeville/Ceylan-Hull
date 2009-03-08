#!/bin/sh

USAGE="
Usage: "`basename $0`" --target-sample-rate FREQUENCY AUDIO_FILENAME
  Resamples the target audio file to the specified frequency, keeping the same bitdepth.
"

if [ ! $# -eq 3 ] ; then

	echo "Error, three parameters expected. ${USAGE}" 1>&2
	exit 5
	
fi


if [ ! "$1" = "--target-sample-rate" ] ; then

	echo "Error, incorrect parameters specified. ${USAGE}" 1>&2
	exit 6
	
fi


target_frequency="$2"
target_file="$3"

if [ -z "${target_file}" ] ; then
	
	echo "Error, no target file specified. ${USAGE}" 1>&2
	exit 10
	
fi


if [ ! -f "${target_file}" ] ; then

	echo "Error, target file (${target_file}) not found." 1>&2
	exit 11

fi


# Prefer any recently self-compiled version:
sox_tool=`PATH=/usr/local/bin:$PATH which sox 2>/dev/null`

if [ ! -x "${sox_tool}" ] ; then

	echo "Error, sox tool not found." 1>&2
	exit 12

fi

#echo "sox_tool = ${sox_tool}"


# Prefer any recently self-compiled version:
soxi_tool=`PATH=/usr/local/bin:$PATH which soxi 2>/dev/null`

if [ ! -x "${soxi_tool}" ] ; then

	echo "Error, soxi tool not found." 1>&2
	exit 13

fi

#echo "soxi_tool = ${soxi_tool}"



echo "Resampling ${target_file} to ${target_frequency} Hz."


# Note: sox command-line options changed, see:
# http://sox.cvs.sourceforge.net/sox/sox/ChangeLog?revision=1.184&view=markup

# Using here a specifically-built Sox from sox-14.2.0.tar.gz, as even Ubuntu 
# was lagging behind.


# See: http://sox.sourceforge.net/Docs/FAQ item #5:

# Phase setting: if resampling to < 40k, use intermediate phase (-I), 
# otherwise use linear phase (-L):
if [ ${target_frequency} -le 40000 ] ; then
	echo " - using intermediate phase (resampling to less than 40 kHz)"
	phase_opt="-I"
else	
	echo " - using linear phase (resampling to more than 40 kHz)"
	phase_opt="-L"
fi 

# Quality setting: using the same bit depth as the one of the input file:
target_bit_depth=`LANG= soxi ${target_file}|grep Precision|sed 's|^Precision      : ||1' | sed 's|-bit$||1'`


# If resampling (or changing speed, as it amounts to the same thing) 
# at/to > 16 bit depth (i.e. most commonly 24-bit), use VHQ (-v), 
# otherwise, use HQ.
if [ ${target_bit_depth} -le 16 ] ; then
	echo " - target bit depth: ${target_bit_depth} bits, using high quality"
	quality_opt="-h"
else
	echo " - target bit depth: ${target_bit_depth} bits, using very high quality"
	quality_opt="-v"
fi

# Bandwidth setting: don't change from the default setting (95%)

# If you're mastering to 16-bit, you also need to add 'dither' 
# (and in most cases noise-shaping) after the rate. 
if [ ${target_bit_depth} -eq 16 ] ; then
	echo " - mastering to 16-bit, using dithering with noise-shaping"
	dither_opt="dither -s"
else
	echo " - not mastering to 16-bit, not using dithering"
	dither_opt=""
fi

tmp_file=".resample.tmp.wav"

# Note: a temporary file *must* be used, otherwise: 
# "Premature EOF on .wav input file"...

# Newer syntax used:
#echo ${sox_tool} "${target_file}" --bits ${target_bit_depth} "${tmp_file}" rate ${quality_opt} ${phase_opt} ${target_frequency} ${dither_opt}

${sox_tool} "${target_file}" --bits ${target_bit_depth} "${tmp_file}" rate ${quality_opt} ${phase_opt} ${target_frequency} ${dither_opt}
 

if [ $? -eq 0 ] ; then

	/bin/mv -f "${tmp_file}" "${target_file}" && echo "File ${target_file} successfully resampled: "`file ${target_file}`
	
else
	echo "Error, resampling of ${target_file} failed." 1>&2
	exit 20
fi		

