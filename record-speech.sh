#!/bin/sh


USAGE="  Usage: "`basename $0`" --voice-id <voice identifier> --speech-prefix <speech identifier> --message <message> [--no-play-back] [--ogg-encoding] [--verbose]

  Records the specified speech with specified voice in specified prefixed filename (default: WAV format), removes leading and ending silences, and plays it back to check it.
      --voice-id <voice identifier>: the ID of the voice to be used (see Asset-Indexing/audio/speech-synthesis/Voice-index.rst)
      --speech-prefix <speech prefix>: the prefix to be used for the speech filename record
      --message <message>: the message to speech
      --no-play-back: disables play-back of the generated sound
      --ogg-encoding: encodes in Ogg Vorbis with default settings the resulting speech
      --verbose: be verbose
"

# See also: Asset-Indexing/audio/speech-synthesis/Speech-Synthesis.rst

# We could/should use http://www.speex.org/ instead of OggVorbis, for voices.
 
# All sound produced as WAV have the following format:
# RIFF (little-endian) data, WAVE audio, Microsoft PCM, 16 bit, mono 22050 Hz


# Defaults:
play_back=0
ogg_encoding=1

resample=0

# Some voices are naturally generated with 10 or 16 kHz instead of the 
# preferred 22.05 kHz, hence must be resampled (knowing that back-ends such
# as SDL_mixer are not able to resample arbitrary frequencies):
target_frequency=22050

trim_silences=0
verbose=1

playback_tool="play-sounds.sh"
playback_tool_exec=`which $playback_tool`

encoder_tool="oggenc"
encoder_tool_exec=`which $encoder_tool`


voice_id=0
speech_prefix=""
message=""


while [ $# -gt 0 ] ; do
	token_eaten=1
	
	if [ "$1" = "--voice-id" ] ; then
    	shift
        voice_id=$1
		token_eaten=0
	fi

	if [ "$1" = "--speech-prefix" ] ; then
    	shift
		speech_prefix="$1"
		token_eaten=0
	fi

	if [ "$1" = "--message" ] ; then
    	shift
		message="$1"
		token_eaten=0
	fi

	if [ "$1" = "--no-play-back" ] ; then
		play_back=1
		token_eaten=0
	fi

	if [ "$1" = "--ogg-encoding" ] ; then
		ogg_encoding=0
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
		echo "Error, unknown argument ($1)." 1>&2
		echo "${USAGE}" 1>&2
        exit 5
	fi	
	shift
    
done



# Checkings:


if [ $voice_id -eq 0 ] ; then
	
	echo "Error, no voice identifier specified." 1>&2
	echo "${USAGE}" 1>&2
	exit 6
        
fi


if [ "$speech_prefix" = "" ] ; then
	
	echo "Error, no speech prefix specified." 1>&2
	echo "${USAGE}" 1>&2
	exit 7
        
fi


if [ -z "$message" ] ; then
	
	echo "Error, no message specified." 1>&2
	echo "${USAGE}" 1>&2
	exit 8
        
fi




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


# Based on Sox:
if [ $resample -eq 0 ] ; then

	resample_tool="resample.sh"
	resampler=`which ${resample_tool} 2>/dev/null`
	
	if [ ! -x "${resampler}" ] ; then
	
		echo "Error, no resampling tool found (${resample_tool})." 1>&2
		exit 14
	
	fi
		
fi


if [ $ogg_encoding -eq 0 ] ; then
	
	if [ ! -x "${encoder_tool_exec}" ] ; then
	
		echo "Error, no OggVorbis encoding tool found (${encoder_tool})." 1>&2
		exit 15
	
	fi
		
fi


if [ $play_back -eq 0 ] ; then

	if [ ! -x "${playback_tool_exec}" ] ; then
	
    	echo "Error, playback tool not found (${playback_tool})." 1>&2
		exit 16
        
    fi
    
fi



# This matching between the voice ID and the tool and voice to use
# must correspond to Content-indexing/audio/speech-synthesis/Voice-index.rst 

tool=""
voice=""

case $voice_id in 

	1)
    	tool="espeak"
        voice="english"
        ;;
    
	2)
    	tool="espeak"
        voice="english-us"
        ;;
	3)
    	tool="espeak"
        voice="en-scottish"
        ;;
	4)
    	tool="espeak"
        voice="default"
        ;;
	5)
    	tool="espeak"
        voice="lancashire"
        ;;
	6)
    	tool="espeak"
        voice="en-westindies"
        ;;
    
	7)
    	tool="espeak"
        voice="english_rp"
        ;;
    
	8)
    	tool="espeak"
        voice="english_wmids"
        ;;
    
	9)
    	tool="espeak"
        voice="french"
        ;;
    
	10)
    	tool="espeak"
        voice="female1"
        ;;
    
	11)
    	tool="espeak"
        voice="female2"
        ;;
    
	12)
    	tool="espeak"
        voice="female3"
        ;;
    
	13)
    	tool="espeak"
        voice="female4"
        ;;
    
	14)
    	tool="espeak"
        voice="male1"
        ;;
    
	15)
    	tool="espeak"
        voice="male2"
        ;;
    
	16)
    	tool="espeak"
        voice="male3"
        ;;
    
	17)
    	tool="espeak"
        voice="male4"
        ;;
    
	18)
    	tool="espeak"
        voice="male6"
        ;;
    
	19)
    	tool="espeak"
        voice="whisper"
        ;;
    
	20)
    	tool="espeak"
        voice="croak"
        ;;
    
    21)
    	tool="festival"
        voice="cmu_us_awb_arctic_clunits"
        ;;
    
    22)
    	tool="festival"
        voice="cmu_us_bdl_arctic_clunits"
        ;;
    
    23)
    	tool="festival"
        voice="cmu_us_clb_arctic_clunits"
        ;;
    
    24)
    	tool="festival"
        voice="cmu_us_jmk_arctic_clunits"
        ;;
    
    25)
    	tool="festival"
        voice="cmu_us_ksp_arctic_clunits"
        ;;
    
    26)
    	tool="festival"
        voice="cmu_us_rms_arctic_clunits"
        ;;
    
    27)
    	tool="festival"
        voice="cmu_us_slt_arctic_clunits"
        ;;
    
    28)
    	tool="festival"
        voice="nitech_us_awb_arctic_hts"
        ;;
    
    29)
    	tool="festival"
        voice="nitech_us_bdl_arctic_hts"
        ;;
    
    30)
    	tool="festival"
        voice="nitech_us_clb_arctic_hts"
        ;;
    
    31)
    	tool="festival"
        voice="nitech_us_jmk_arctic_hts"
        ;;
    
    32)
    	tool="festival"
        voice="nitech_us_rms_arctic_hts"
        ;;
    
    33)
    	tool="festival"
        voice="nitech_us_slt_arctic_hts"
        ;;
    
    34)
    	tool="festival"
        voice="kal_diphone"
        ;;
    
    35)
    	tool="festival"
        voice="ked_diphone"
        ;;
    
    36)
    	tool="festival"
        voice="rab_diphone"
        ;;
    
    37)
    	tool="festival"
        voice="don_diphone"
        ;;
       
    *)
    	echo "Error, voice identifier #$voice_id not known." 1>&2
        exit 10
    	;;    
        
esac

target_wav="$speech_prefix.wav"



if [ $verbose -eq 0 ] ; then
    
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

            
	if [ $ogg_encoding -eq 0 ] ; then
    	echo " - OggVorbis encoding selected"
	else
    	echo " - OggVorbis encoding not selected"
	fi

	if [ $play_back -eq 0 ] ; then
    	echo " - play-back selected"
	else
    	echo " - play-back not selected"
	fi
    

    echo " - voice identifier: $voice_id"
    
    echo " - speech prefix: $speech_prefix"
    
    echo " - message: $message"

fi




# Actual operations:


if [ "$tool" = "espeak" ] ; then

	# Default amplitude, pitch and speed left as default:
	espeak -v $voice -w "$target_wav" "$message"
	
	if [ ! $? -eq 0 ] ; then
		echo "Error, generation of $target_wav with $tool failed." 1>&2
		exit 20
	fi
    
else 

	if [ "$tool" = "festival" ] ; then

		echo "$message" | text2wave -otype riff -o "$target_wav" -eval "(voice_$voice)"

		if [ ! $? -eq 0 ] ; then
			echo "Error, generation of $target_wav with $tool failed." 1>&2
			exit 21
		fi
    
	else
	
    	echo "Error, tool '$tool' not known." 1>&2
	    exit 11
        
    fi
    
fi


if [ ! -f "$target_wav" ] ; then

    echo "Error, produced WAV not found ($target_wav)." 1>&2
    exit 12
	
fi

echo "$target_wav successfully generated by $tool."

effective_target="$target_wav"


if [ $trim_silences -eq 0 ] ; then

	${trimmer} "$target_wav"

    if [ ! $? -eq 0 ] ; then
		echo "Error, trimming of ${target_wav} failed." 1>&2
		exit 13
	fi
	
fi


if [ $resample -eq 0 ] ; then

	${resample_tool} --target-sample-rate ${target_frequency} ${target_wav}
		
    if [ ! $? -eq 0 ] ; then
		echo "Error, resampling of ${target_wav} failed." 1>&2
		exit 14
	fi
	
fi



if [ $ogg_encoding -eq 0 ] ; then

	echo "Encoding with ${encoder_tool}"
	
	target_ogg="$speech_prefix.ogg"
    
	# Quality ranges between -1 (very low) and 10 (very high),
	# 3 is the encoder default (we suppose it is VBR indeed, must be the case):
	${encoder_tool} "$target_wav" --discard-comments --quality=3 --output="$target_ogg" 1>/dev/null 2>&1
	
    if [ ! $? -eq 0 ] ; then
		echo "Error, encoding of ${target_wav} failed." 1>&2
	fi
    
    effective_target="$target_ogg"
    
fi


if [ $play_back -eq 0 ] ; then

	${playback_tool} "$effective_target"
	
    if [ ! $? -eq 0 ] ; then
		echo "Error, playback failed." 1>&2
	fi
        
fi

