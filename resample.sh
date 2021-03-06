#!/bin/sh

usage="
Usage: $(basename $0) --target-sample-rate FREQUENCY AUDIO_FILENAME
  Resamples the target audio file to the specified frequency, keeping the same bitdepth. Advances settings are chosen, and gain is finely tuned if necessary, to avoid clipping.
Example: $(basename $0) --target-sample-rate 22050 mySound.wav"


if [ ! $# -eq 3 ]; then

	echo "Error, three parameters expected. ${usage}" 1>&2
	exit 5

fi


if [ ! "$1" = "--target-sample-rate" ]; then

	echo "Error, incorrect parameters specified. ${usage}" 1>&2
	exit 6

fi


target_frequency="$2"
target_file="$3"

if [ -z "${target_file}" ]; then

	echo "Error, no target file specified. ${usage}" 1>&2
	exit 10

fi


if [ ! -f "${target_file}" ]; then

	echo "Error, target file (${target_file}) not found." 1>&2
	exit 11

fi


# Prefer any recently self-compiled version:
sox_tool=$(PATH=/usr/local/bin:$PATH which sox 2>/dev/null)

if [ ! -x "${sox_tool}" ]; then

	echo "Error, sox tool not found." 1>&2
	exit 12

fi

#echo "sox_tool = ${sox_tool}"


# Prefer any recently self-compiled version:
soxi_tool=$(PATH=/usr/local/bin:$PATH which soxi 2>/dev/null)

if [ ! -x "${soxi_tool}" ]; then

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
if [ ${target_frequency} -le 40000 ]; then
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
if [ ${target_bit_depth} -le 16 ]; then
	echo " - target bit depth: ${target_bit_depth} bits, using high quality"
	quality_opt="-h"
else
	echo " - target bit depth: ${target_bit_depth} bits, using very high quality"
	quality_opt="-v"
fi

# Bandwidth setting: don't change from the default setting (95%)

# If you're mastering to 16-bit, you also need to add 'dither'
# (and in most cases noise-shaping) after the rate.
if [ ${target_bit_depth} -eq 16 ]; then
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

# Tries to resample first without attenuation:
attenuation_factor=0
attenuation_opt=""

log_file=".resample.txt"

clipped=0



# We want to resample with clipping, various options exist:

used_solution=1


# Solution 1: first to be used, working but maybe a bit too heavy.
# Decreases the volume as long as samples had to be clipped:
if [ $used_solution -eq 1 ]; then

	while [ $clipped -eq 0 ]; do

		${sox_tool} "${target_file}" --bits ${target_bit_depth} --comment "" "${tmp_file}" ${attenuation_opt} rate ${quality_opt} ${phase_opt} ${target_frequency} ${dither_opt} 2>${log_file}

		res=$?

		if grep 'rate clipped' ${log_file} 1>/dev/null 2>&1; then

			attenuation_factor=$(($attenuation_factor+1))
			echo "Resampler had to perform clipping, decreasing volume: attenuation is now $attenuation_factor."
			attenuation_opt="gain -${attenuation_factor}"

		else

			echo "No clipping detected."
			clipped=1

		fi

	done

	/bin/rm -f ${log_file}


elif [ $used_solution -eq 2 ]; then


# Solution 2: simpler but unfortunately fails with some files
# (with "FAIL gain: can't reclaim headroom"):

# Use gain -h / gain -r to perform the appropriate attenuation, based on
# headroom (attenuates only if necessary to prevent clipping):

	${sox_tool} "${target_file}" --bits ${target_bit_depth} --comment "" "${tmp_file}" gain -h rate ${quality_opt} ${phase_opt} ${target_frequency} gain -r ${dither_opt}


elif [ $used_solution -eq 3 ]; then

# Solution 3: quite simple again (not working, not resampling):

	loudest_clippless_volume=$(${sox_tool} "${target_file}" -n stat -v)

	${sox_tool} "${target_file}" "${tmp_file}" vol ${loudest_clippless_volume}

fi


res=$?

if [ $res -eq 0 ]; then

	/bin/mv -f "${tmp_file}" "${target_file}" && echo "File ${target_file} successfully resampled: "`file ${target_file}`

else

	echo "Error, resampling of ${target_file} failed ($res)." 1>&2
	exit 20

fi
