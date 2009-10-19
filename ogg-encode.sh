#!/bin/sh


USAGE="  Usage: "`basename $0`"  [--play-back] [--verbose] AUDIO_FILENAME

  Encodes specified sound file in OggVorbis after having removed any leading and ending silences, adjusting volume.
      --play-back: enables play-back of the generated sound
      --verbose: be verbose
"

# Regarding size, quality, sample rates: 
#
# For a source file of 30 Mb, we had in terms of Ogg-encoded files:
#
#  - quality 3:
#    + sample rate 22050 Hz: 2.5 Mb
#    + sample rate 44100 Hz: 4 Mb
#  - quality 4:
#    + sample rate 22050 Hz: 2.8 Mb
#    + sample rate 44100 Hz: 4.6 Mb
#
# Although no real difference could be heard between quality 3 at 22050 Hz
# and quality 4 at 44100 Hz, we went for the latter, as we start from
# good-quality assets that deserve it. 
#
# So quality 4 with sample rate 44100 Hz seems to be a good trade-off, size is
# already divided by more than 6.



# Defaults:

verbose=1

trim_silences=0


resample=0

# Some audio files are naturally generated with 10, 16 kHz or any other
# frequence instead of the preferred 22.05 kHz, hence must be resampled
# (knowing that back-ends such as SDL_mixer are not able to resample arbitrary
# frequencies):
#target_frequency=22050
target_frequency=44100


# Input files may have very different volumes, too loud or, often not enough.
# The goal here is to ensure it is high enough without risking clipping,
# thanks to headroom.
# See http://sox.sourceforge.net/sox.html#lbAK
adjust_volume=0

norm_level="-3"

ogg_encoding=0

encoder_tool="oggenc"

#ogg_quality=3
ogg_quality=4


play_back=1

playback_tool="play-sounds.sh"
playback_tool_exec=`which $playback_tool`




while [ $# -gt 0 ] ; do
	token_eaten=1
	

	if [ "$1" = "--play-back" ] ; then
		play_back=0
		token_eaten=0
	fi


	if [ "$1" = "--verbose" ] ; then
		verbose=0
		token_eaten=0
	fi

	
	if [ "$1" = "-h" -o "$1" = "--help" ] ; then
		echo "${USAGE}"
		exit
		token_eaten=0
	fi


	if [ $token_eaten -eq 1 ] ; then
		
		if [ $# -eq 1 ] ; then
			input_file="$1"
		else
			echo "Error, too many remaining arguments ($*)." 1>&2
			echo "${USAGE}" 1>&2
			exit 5
		fi
		
	fi	
	shift
    
done


effective_target="$input_file"

if [ -z "$effective_target" ] ; then
	echo "Error, no input sound file specified." 1>&2
	echo "${USAGE}" 1>&2
	exit 6

fi


# Checkings:


# Almost always interesting, as sox is used, thus correcting any malformed
# input sound file:
if [ $trim_silences -eq 0 ] ; then

	trimmer_tool="trimSilence.sh"
	trimmer=`which ${trimmer_tool} 2>/dev/null`
	
	if [ ! -x "${trimmer}" ] ; then
	
		echo "Error, no trimming tool found (${trimmer_tool})." 1>&2
		exit 13
	
	fi
		
fi



# Based on sox too:
if [ $resample -eq 0 ] ; then

	resample_tool="resample.sh"
	resampler=`which ${resample_tool} 2>/dev/null`
	
	if [ ! -x "${resampler}" ] ; then
	
		echo "Error, no resampling tool found (${resample_tool})." 1>&2
		exit 14
	
	fi
		
fi


if [ $adjust_volume -eq 0 ] ; then

	sox_tool=`PATH=/usr/local/bin:$PATH which sox 2>/dev/null`

	if [ ! -x "${sox_tool}" ] ; then

		echo "Error, sox tool not found." 1>&2
		exit 15

	fi

	#echo "sox_tool = $sox_tool"
	
fi


if [ $play_back -eq 0 ] ; then

	if [ ! -x "${playback_tool_exec}" ] ; then
	
    	echo "Error, playback tool not found (${playback_tool})." 1>&2
		exit 16
        
    fi
    
fi



if [ ! -f "$effective_target" ] ; then

    echo "Error, specified input file not found ($effective_target)." 1>&2
    exit 17
	
fi



if [ $verbose -eq 0 ] ; then
  
    echo " - input file: $effective_target"
   

	if [ $trim_silences -eq 0 ] ; then
    	echo " - silences will be trimmed"
	else
    	echo " - no trimming of silences performed"
	fi
    
	if [ $resample -eq 0 ] ; then
    	echo " - resampling to ${target_frequency} Hz will be performed"
	else
    	echo " - no resampling performed"
	fi

	if [ $adjust_volume -eq 0 ] ; then
    	echo " - volume adjustment will be performed, at ${norm_level}dB"
	else
    	echo " - no volume adjustment will be performed"
	fi

    echo " - encoding to OggVorbis quality $ogg_quality will be performed"
	
	if [ $play_back -eq 0 ] ; then
    	echo " - play-back selected"
	else
    	echo " - play-back not selected"
	fi
	
fi




# Actual operations:


if [ $trim_silences -eq 0 ] ; then

	# Trimming will alter the specified file, operating on a copy instead:
	copied_source="trimmed-$effective_target"
	
	/bin/cp -f "$effective_target" "$copied_source"
	chmod +w "$copied_source"
	
	${trimmer} "$copied_source"

    if [ ! $? -eq 0 ] ; then
		echo "Error, trimming of $effective_target failed." 1>&2
		/bin/rm -f "$copied_source"
		exit 13
	fi
		
	
	effective_target="$copied_source"
	
fi


if [ $resample -eq 0 ] ; then

	${resample_tool} --target-sample-rate ${target_frequency} $effective_target
		
    if [ ! $? -eq 0 ] ; then
		echo "Error, resampling of $effective_target failed." 1>&2
		exit 14
	fi
	
fi


if [ $adjust_volume -eq 0 ] ; then

	echo "Adjusting volume of ${effective_target}: normalizing to ${norm_level}dB"
	
	ajusted_version="adjusted-${effective_target}"
	
	# 'contrast' effect not used, sound would be too distorted, and we do not
	# want to change the dynamic range.
	# We just want the volume to be reasonably high: not too low, so that the
	# playback can be as loud as wanted, not too high, otherwise mixing with
	# other sounds would induce clipping.
	# So actually we just want to normalize to a certain level 
	# (negative,to ensure we leave some headroom), here 3dB.
	# See also: http://en.wikipedia.org/wiki/Audio_normalization
	
	# Instead of 'contrast', 'compand' could be used, for sounds not loud 
	# enough.
	
	${sox_tool} ${effective_target} ${ajusted_version} gain -n ${norm_level}
	
    if [ ! $? -eq 0 ] ; then
		echo "Error, adjusting the volume of $effective_target failed." 1>&2
		exit 15
	fi
	
	# Make some cleaning:
	if [ ! "$effective_target" = "$input_file" ] ; then
		/bin/rm -f "$effective_target"
	fi
	
	effective_target="$ajusted_version"
	
fi


if [ $ogg_encoding -eq 0 ] ; then

	echo "Encoding with ${encoder_tool}, with quality ${ogg_quality}"
	
	# Replaces extension by '.ogg' :
	target_ogg=`echo "$input_file" | sed 's|\..*$|.ogg|1'`
    
	# Quality ranges between -1 (very low) and 10 (very high),
	# 3 is the encoder default (we suppose it is VBR indeed, must be the case):
	${encoder_tool} "$effective_target" --discard-comments --quality=${ogg_quality} --output="$target_ogg" 1>/dev/null 2>&1
	
    if [ ! $? -eq 0 ] ; then
		echo "Error, encoding of $effective_target failed." 1>&2
		exit 20
	fi

	# Make some cleaning:
	if [ ! "$effective_target" = "$input_file" ] ; then
		/bin/rm -f "$effective_target"
	fi
	
    effective_target="$target_ogg"

	echo "Encoding of $effective_target succeeded."     
	
fi


if [ $play_back -eq 0 ] ; then

	${playback_tool} "$effective_target"
	
    if [ ! $? -eq 0 ] ; then
		echo "Error, playback failed." 1>&2
	fi
        
fi

